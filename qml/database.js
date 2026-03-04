
// Database
const dbName = "cookbookDB"
const dbVersion = "1.0"
const dbDescription = "Database for cookbooks"
const dbEstimatedSize = 10000
const db = LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription, dbEstimatedSize)

const initializeDB = () => {

  try {
    db.transaction(tx => {

      // Create accounts table if it does not exsist
      tx.executeSql(
        'CREATE TABLE IF NOT EXISTS '
        + 'accounts'
        + ' (name TEXT, hash TEXT)'
      );
      // Create categories table if it does not exsist
      tx.executeSql(
        'CREATE TABLE IF NOT EXISTS '
        + 'categories'
        + ' (name TEXT, recipe_count INTEGER)'
      );
      // Create recipes_meta table if it does not exsist
      tx.executeSql(
        'CREATE TABLE IF NOT EXISTS '
        + 'recipes_meta'
        + ` (
              name TEXT,
              keywords TEXT,
              dateCreated DATETIME,
              dateModified DATETIME,
              imageUrl TEXT,
              imagePlaceholderUrl TEXT,
              id INTEGER PRIMARY_KEY
          )`
      );
      // Create recipes table if it does not exsist
      tx.executeSql(
        'CREATE TABLE IF NOT EXISTS '
        + 'recipes'
        + ` (
            name TEXT,
            description TEXT,
            recipeYield INTEGER,
            prepTime DATETIME,
            cookTime DATETIME,
            totalTime DATETIME,
            url TEXT,
            image TEXT,
            recipeCategory TEXT,
            keywords TEXT,
            dateCreated DATETIME,
            dateModified DATETIME,
            imageUrl TEXT,
            localImageUrl TEXT,
            imagePlaceholderUrl TEXT,
            localImagePlaceholderUrl TEXT,
            id INTEGER PRIMARY_KEY
        )`
        // tool,
        // recipeIngredient,
        // resipeInstructions,
        // nutrition,
      );

      // create ingredients table if it does not exist
      tx.executeSql(
        'CREATE TABLE IF NOT EXISTS '
        + 'ingredients'
        + ` (
            name TEXT,
            recipeId INTEGER,
            FOREIGN KEY (recipeId) REFERENCES recipes(recipeId)
        )`
      )

      tx.executeSql(
        'CREATE TABLE IF NOT EXISTS '
        + 'instructions'
        + ` (
            name TEXT,
            recipeId INTEGER,
            FOREIGN KEY (recipeId) REFERENCES recipes(recipeId)
        )`
      )

      // Create logs table if it does not exist
      tx.executeSql(
        'CREATE TABLE IF NOT EXISTS '
        + 'logs'
        + ` (
            timeStamp DATETIME,
            domain TEXT,
            status TEXT,
            message TEXT
        )`
      )

    addLogEntry("database", "info", `Database initialised`)
    })
  } catch (err) {
    addLogEntry("database", "ERROR", `Error creating/reading table in database: ${err}`)
  }
}

const purgeDatabase = () => {
  db.transaction(tx => {
    tx.executeSql('DROP TABLE recipes_meta')
    tx.executeSql('DROP TABLE recipes')
    tx.executeSql('DROP TABLE ingredients')
    tx.executeSql('DROP TABLE instructions')
  })
  addLogEntry("database", "info", `Database purged (all tables dropped)`)
  initializeDB()
}

const purgeLogs = () => {
  db.transaction(tx => {
    tx.executeSql('DROP TABLE logs')
  })
}

const addLogEntry = (domain, status, message) => {
  db.transaction(tx => {
    tx.executeSql(
      'INSERT INTO logs '
      + `(
          timeStamp,
          domain,
          status,
          message
        ) VALUES(?, ?, ?, ?)`,
      [
        new Date(),
        domain,
        status,
        message
      ]
    );
  })
}

const getLogs = () => {
  return new Promise((resolve, reject) => {
    var logs = [];
    db.transaction(tx => {
      var dbLogs = tx.executeSql(
        `SELECT
        timeStamp,
        domain,
        status,
        message
        FROM logs ORDER BY timeStamp DESC
      `
      );
      for (let i = 0; i < dbLogs.rows.length; i++) {
        logs.push(dbLogs.rows.item(i))
      }
      resolve(logs)
    })
  })
}

const checkForUpdates = (url, auth) => {
  const dbMeta = [];

  return new Promise((resolve, reject) => {
    addLogEntry("database", "info", "Checking for updates on server")

    db.transaction(tx => {
      const currentRecipesMeta = tx.executeSql('SELECT * FROM recipes_meta')
      for (let i = 0; i < currentRecipesMeta.rows.length; i++) {
        dbMeta.push(currentRecipesMeta.rows[i])
      }
    })

    const updatedRecipes = [];
    const addedRecipes = [];
    const deletedRecipes = [];

    Server.getRecipesMeta(url, auth)
      .then(recipes => {
        recipes.forEach(recipe => {
          // Check if recipe ID exists in db
          if (dbMeta.map(res => res.id).includes(parseInt(recipe.id))) {
            //  - YES -> Check if recipe has more recent change date.
            if (recipe.dateModified > dbMeta.find(res => {
              return res.id == parseInt(recipe.id)
            }).dateModified) {
              //    - YES -> Update recipe
              const updateRecipeMessage = "Updating recipe: "
              updatedRecipes.push(new Promise((resolve, reject) => Server.getRecipe(url, auth, parseInt(recipe.id))
                .then(rec => {
                  const imageMessage = "Downloading image for recipe: "
                  return Server.getImage(url, auth, rec.imageUrl)
                    .then(url => {
                      rec.localImagePlaceholderUrl = url
                      addLogEntry("database", "OK", imageMessage + `'${recipe.name}' - OK`)
                      return rec
                    })
                    .catch(error => {
                      addLogEntry("database", "WARNING", imageMessage + `'${recipe.name}' - No image found`)
                      rec.localImagePlaceholderUrl = ""
                      return rec
                    })
                })
                .then(rec => {
                  updateRecipeMeta(recipe)
                  updateRecipe(rec)
                  return
                })
                .then(() => {
                  addLogEntry("database", "OK", updateRecipeMessage + `'${recipe.name}' - OK`)
                  resolve()
                })
                .catch(error => {
                  addLogEntry("database", "ERROR", updateRecipeMessage + `'${recipe.name}' - Error: ${error}`)
                  reject()
                })
              ))
            }
          } else {
            //  - NO -> New recipe; add
            const addRecipeMessage = "Adding recipe: "
            addedRecipes.push(new Promise((resolve, reject) => Server.getRecipe(url, auth, parseInt(recipe.id))
              .then(rec => {
                const imageMessage = "Downloading image for recipe: "
                return Server.getImage(url, auth, recipe.imageUrl)
                  .then(url => {
                    rec.localImagePlaceholderUrl = url
                    addLogEntry("database", "OK", imageMessage + `'${recipe.name}' - OK`)
                    return rec
                  })
                  .catch(error => {
                    addLogEntry("database", "WARNING", imageMessage + `'${recipe.name}' - No image found`)
                    rec.localImagePlaceholderUrl = ""
                    return rec
                  })
              })
              .then(rec => {
                addRecipeMeta(recipe)
                addRecipe(rec)
                return
              })
              .then(() => {
                addLogEntry("database", "OK", addRecipeMessage + `'${recipe.name}' - OK`)
                resolve()
              })
              .catch(error => {
                addLogEntry("database", "ERROR", addRecipeMessage + `'${recipe.name}' - Error: ${error}`)
                reject()
              })
            ))
          }
        })

        dbMeta.forEach(recipe => {
          // Check if db recipe ID exists in updated meta
          if (!recipes.map(res => parseInt(res.id)).includes(recipe.id)) {
            //  - NO -> recipe deleted; delete
            addLogEntry("database", "info", `Deleting recipe not found upstream: '${recipe.name}'`)
            removeRecipeMeta(recipe.id)
            removeRecipe(recipe.id)
            deletedRecipes.push(recipe.id)
          }
        })
      }).then(() => {
        Promise.all([...updatedRecipes, ...addedRecipes])
          .then(() => {
            addLogEntry("database", "OK", `Sync with Nextcloud server OK: ${addedRecipes.length} added, ${updatedRecipes.length} updated and ${deletedRecipes.length} deleted`)
            resolve(
              i18n.tr("Recipes sucsessfully updated from Nextcloud server")
            )
          })
      }).catch(error => {
        addLogEntry("database", "ERROR", `Could not fetch recipes from server: '${error}'`)
        reject(
          // TRANSLATORS: %1 is the error message returned
          i18n.tr('Could not fetch recipes from server: %1').arg(error)
        )
      })
  })
}

const getEmptyRecipe = () => {
  return ({
    name: "",
    description: "",
    recipeYield: "",
    prepTime: "",
    cookTime: "",
    totalTime: "",
    url: "",
    image: "",
    recipeCategory: "",
    keywords: "",
    dateCreated: "",
    dateModified: "",
    imageUrl: "",
    imagePlaceholderUrl: "",
    localImagePlaceholderUrl: "",
    recipeIngredient: [],
    recipeInstructions: [],
    id: "",
    tool: [],
    nutrition: [],
  })
}

const addRecipe = (recipe) => {
  db.transaction(tx => {
    tx.executeSql(
      `INSERT INTO recipes (
        name,
        description,
        recipeYield,
        prepTime,
        cookTime,
        totalTime,
        url,
        image,
        recipeCategory,
        keywords,
        dateCreated,
        dateModified,
        imageUrl,
        imagePlaceholderUrl,
        localImagePlaceholderUrl,
        id 
      )
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        recipe.name,
        recipe.description,
        recipe.recipeYield,
        recipe.prepTime,
        recipe.cookTime,
        recipe.totalTime,
        recipe.url,
        recipe.image,
        recipe.recipeCategory,
        recipe.keywords,
        recipe.dateCreated,
        recipe.dateModified,
        recipe.imageUrl,
        recipe.imagePlaceholderUrl,
        recipe.localImagePlaceholderUrl,
        parseInt(recipe.id)
      ]
    );

    if (recipe.recipeIngredient) {
      recipe.recipeIngredient.forEach(ingredient => {
        tx.executeSql(
          `INSERT INTO ingredients (
             name,
             recipeId
             ) VALUES(?, ?)`,
          [
            ingredient,
            parseInt(recipe.id)
          ]
        );
      })
    }
    if (recipe.recipeInstructions) {
      recipe.recipeInstructions.forEach(instruction => {
        tx.executeSql(
          `INSERT INTO instructions (
             name,
             recipeId
             ) VALUES(?, ?)`,
          [
            instruction,
            parseInt(recipe.id)
          ]
        );
      })
    }
    // recipe.tool,
    // recipe.recipeIngredient,
    // recipe.resipeInstructions,
    // recipe.nutrition,
  })
}

const updateRecipe = (recipe) => {
  db.transaction(tx => {
    tx.executeSql(
      `UPDATE recipes set
        name=?,
        description=?,
        recipeYield=?,
        prepTime=?,
        cookTime=?,
        totalTime=?,
        url=?,
        image=?,
        recipeCategory=?,
        keywords=?,
        dateCreated=?,
        dateModified=?,
        imageUrl=?,
        imagePlaceholderUrl=?,
        localImagePlaceholderUrl=?
        WHERE id=?
      `,
      [
        recipe.name,
        recipe.description,
        recipe.recipeYield,
        recipe.prepTime,
        recipe.cookTime,
        recipe.totalTime,
        recipe.url,
        recipe.image,
        recipe.recipeCategory,
        recipe.keywords,
        recipe.dateCreated,
        recipe.dateModified,
        recipe.imageUrl,
        recipe.imagePlaceholderUrl,
        recipe.localImagePlaceholderUrl,
        parseInt(recipe.id)
      ]
    );

    tx.executeSql(
      'DELETE FROM ingredients WHERE recipeId=?',
      [recipe.id]
    )
    tx.executeSql(
      'DELETE FROM instructions WHERE recipeId=?',
      [recipe.id]
    )

    if (recipe.recipeIngredient) {
      recipe.recipeIngredient.forEach(ingredient => {
        tx.executeSql(
          `INSERT INTO ingredients (
             name,
             recipeId
             ) VALUES(?, ?)`,
          [
            ingredient,
            parseInt(recipe.id)
          ]
        );
      })
    }
    if (recipe.recipeInstructions) {
      recipe.recipeInstructions.forEach(instruction => {
        tx.executeSql(
          `INSERT INTO instructions (
             name,
             recipeId
             ) VALUES(?, ?)`,
          [
            instruction,
            parseInt(recipe.id)
          ]
        );
      })
    }
    // recipe.tool,
    // recipe.recipeIngredient,
    // recipe.resipeInstructions,
    // recipe.nutrition,
  })
}

const getCategories = () => {
  return new Promise(resolve => {
    db.transaction(tx => {
      var dbCategories = tx.executeSql(
        `SELECT COUNT(*) AS count, recipeCategory FROM recipes GROUP BY recipeCategory`
      )
      var dbAllRecipes = tx.executeSql(
        `SELECT COUNT(*) AS count FROM recipes`
      )
      var categories = [];
      for (let i = 0; i < dbCategories.rows.length; i++) {
        categories.push(dbCategories.rows.item(i))
      }
      categories.unshift({ recipeCategory: i18n.tr('All recipes'), count: dbAllRecipes.rows.item(0).count })
      resolve(categories)
    })
  })
}

const getCategoryRecipesMeta = (category) => {
  return new Promise(resolve => {
    db.transaction(tx => {
      var dbRecipes;
      switch (category) {
        case i18n.tr('All recipes'):
          dbRecipes = tx.executeSql(
            `SELECT
              name,
              keywords,
              dateCreated,
              dateModified,
              imageUrl,
              imagePlaceholderUrl,
              localImagePlaceholderUrl,
              id
              FROM recipes
            `
          );
          break;
        case 'Uncategorized':
          dbRecipes = tx.executeSql(
            `SELECT
              name,
              keywords,
              dateCreated,
              dateModified,
              imageUrl,
              imagePlaceholderUrl,
              localImagePlaceholderUrl,
              id
              FROM recipes WHERE recipeCategory IS NULL
            `
          )
          break;
        default:
          dbRecipes = tx.executeSql(
            `SELECT
              name,
              keywords,
              dateCreated,
              dateModified,
              imageUrl,
              imagePlaceholderUrl,
              localImagePlaceholderUrl,
              id
              FROM recipes WHERE recipeCategory=?`,
            [category]
          )
      }

      var recipes = [];
      for (let i = 0; i < dbRecipes.rows.length; i++) {
        recipes.push(dbRecipes.rows.item(i))
      }
      resolve(recipes)
    })
  })
}

const getRecipe = (id) => {

  return new Promise((resolve, reject) => {
    db.readTransaction(tx => {
      var dbRecipe = tx.executeSql(
        'SELECT * FROM recipes WHERE id=?',
        [id]
      );
      if (dbRecipe.rows.length == 0) reject()
      var dbIngredients = tx.executeSql(
        'SELECT name FROM ingredients WHERE recipeId=?',
        [id]
      );
      var dbInstructions = tx.executeSql(
        'SELECT name FROM instructions WHERE recipeId=?',
        [id]
      );
      var recipe = dbRecipe.rows.item(0)
      var ingredients = [];
      var instructions = [];

      for (let i = 0; i < dbIngredients.rows.length; i++) {
        ingredients.push(dbIngredients.rows.item(i).name)
      }
      for (let i = 0; i < dbInstructions.rows.length; i++) {
        instructions.push(dbInstructions.rows.item(i).name)
      }

      recipe.recipeIngredient = ingredients
      recipe.recipeInstructions = instructions
      resolve(recipe)
    })
  })
}

const addRecipeMeta = (recipe) => {
  return new Promise(resolve => {
    db.transaction(tx => {
      tx.executeSql(
        'INSERT INTO recipes_meta '
        + `(
          name,
          keywords,
          dateCreated,
          dateModified,
          imageUrl,
          imagePlaceholderUrl,
          id
        ) VALUES(?, ?, ?, ?, ?, ?, ?)`,
        [
          recipe.name,
          recipe.keywords,
          recipe.dateCreated,
          recipe.dateModified,
          recipe.imageUrl,
          recipe.imagePlaceholderUrl,
          parseInt(recipe.id)
        ]
      );
    })
    resolve()
  })
}

const updateRecipeMeta = (recipe) => {
  db.transaction(tx => {
    tx.executeSql(
      `UPDATE recipes_meta set 
        name=?,
        keywords=?,
        dateCreated=?,
        dateModified=?,
        imageUrl=?,
        imagePlaceholderUrl=?
        WHERE id=?
      `,
      [
        recipe.name,
        recipe.keywords,
        recipe.dateCreated,
        recipe.dateModified,
        recipe.imageUrl,
        recipe.imagePlaceholderUrl,
        parseInt(recipe.id)
      ]
    )
  })
}

const removeRecipeMeta = (id) => {
  db.transaction(tx => {
    tx.executeSql(
      'DELETE FROM recipes_meta WHERE id=?',
      [id]
    )
  })
}

const removeRecipe = (id) => {
  db.transaction(tx => {
    tx.executeSql(
      'DELETE FROM recipes WHERE id=?',
      [id]
    )
    tx.executeSql(
      'DELETE FROM ingredients WHERE recipeId=?',
      [id]
    )
    tx.executeSql(
      'DELETE FROM instructions WHERE recipeId=?',
      [id]
    )
  })
}

