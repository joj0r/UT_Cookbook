const apiCall = (url, auth, method, param = "", recipe) => {
  var xhr = new XMLHttpRequest();

  function Timer() {
    return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
  }

  return new Promise((resolve, reject) => {

    var timer = new Timer();
    timer.interval = 15000;
    timer.triggered.connect(function() {
      reject(i18n.tr("Request timed out"))
    })

    try {
      timer.start();
      xhr.onreadystatechange = () => {
        if (xhr.readyState === XMLHttpRequest.DONE) {
          if (xhr.status === 200) {
            timer.stop()
            resolve(JSON.parse(xhr.responseText.toString()));
          }
          reject(xhr.status + ' ' + xhr.statusText)
        }
      }

      xhr.open(method, url + param);
      xhr.setRequestHeader(
        'Authorization', 'Basic ' + auth
      )
      xhr.setRequestHeader(
        'Accept', 'application/json'
      )
      xhr.setRequestHeader(
        'Content-Type', 'application/json;charset=UTF-8'
      )
      if (recipe) {
        xhr.send(JSON.stringify(recipe));
      } else
        xhr.send();
    } catch (e) {
      reject(e.message + '\nAre you online?')
    }
  });

}

const getRecipesMeta = (url, auth) => {
  const endpointUrl = "/apps/cookbook/api/v1/recipes"

  return apiCall(url + endpointUrl, auth, "GET")
}

const importRecipe = (url, auth, recipeUrl) => {
  const endpointUrl = "/apps/cookbook/api/v1/import"

  return new Promise((resolve, reject) => {
    apiCall(url + endpointUrl, auth, "POST", "", recipeUrl)
      .then(result => resolve(result))
      .catch(error => reject(
        // TRANSLATORS: %1 is the error message returned
        i18n.tr('Importing recipe failed: %1').arg(error))
      )
  })
}

const createRecipe = (url, auth, recipe) => {
  const endpointUrl = "/apps/cookbook/api/v1/recipes"

  return new Promise((resolve, reject) => {
    apiCall(url + endpointUrl, auth, "POST", "", recipe)
      .then(result => resolve(result))
      .catch(error => reject(
        // TRANSLATORS: %1 is the error message returned
        i18n.tr('Creating recipe failed: %1').arg(error))
      )
  })
}

const updateRecipe = (url, auth, id, recipe) => {
  const endpointUrl = "/apps/cookbook/api/v1/recipes/"

  return new Promise((resolve, reject) => {
    apiCall(url + endpointUrl, auth, "PUT", id, recipe)
      .then(result => resolve(result))
      .catch(error => reject(
        // TRANSLATORS: %1 is the error message returned
        i18n.tr('Updating recipe failed: %1').arg(error))
      )
  })
}

const deleteRecipe = (url, auth, id) => {
  const endpointUrl = "/apps/cookbook/api/v1/recipes/"

  return new Promise((resolve, reject) => {
    apiCall(url + endpointUrl, auth, "DELETE", id)
      .then(result => resolve(result))
      .catch(error => reject(
        // TRANSLATORS: %1 is recipe id, %2 is the error message returned
        i18n.tr('Deleting recipe %1 failed: %2').arg(id).arg(error))
      )
  })
}


const getRecipe = (url, auth, id) => {
  const endpointUrl = "/apps/cookbook/api/v1/recipes/"

  return new Promise((resolve, reject) => {
    apiCall(url + endpointUrl, auth, "GET", id)
      .then(result => resolve(result))
      .catch(error => reject(
        // TRANSLATORS: %1 is recipe id, %2 is the error message returned
        i18n.tr('%1 is recipe id, %2 is error message', 'Fetching recipe %1 failed: %2').arg(id).arg(error))
      )
  })
}

const getImage = (url, auth, imageUrl) => {

  return new Promise((resolve, reject) => {

    function Downloader() {
      return Qt.createQmlObject(`
        import Lomiri.DownloadManager 1.2; 
        SingleDownload {
        }
        `, root);
    }

    function Timer() {
      return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
    }

    var timer = new Timer();
    timer.interval = 10000;
    timer.triggered.connect(function() {
      reject(i18n.tr("Image download timed out"))
    })

    var downloader = new Downloader();
    downloader.headers = {
      'authorization': 'basic ' + auth
    }

    timer.start();

    downloader.download(url + imageUrl);

    downloader.finished.connect((url) => {
      timer.stop()
      resolve(url)
    })
  });
}
