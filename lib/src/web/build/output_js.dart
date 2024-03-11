final String jsString = r'''var injectedData;

window.onload = function () {
  dragUi();
  // IF IT IS INJECTED THEN IT WILL BE DOWNLOADED
  if(!injectedData){
    handleAutoReconnect();
  }else{
    renderInjectedData();
  }
  if (typeof (navigator.clipboard) == 'undefined') {
    document.getElementById('copy_btn').style.display = 'none';
  }
}

function convertMilliseconds(milliseconds) {
  // if its not number then return milliseconds
  if (isNaN(milliseconds)) {
    return milliseconds;
  }
  if (milliseconds >= 60000) {
    // Convert to minutes
    return (milliseconds / 60000).toFixed(2) + " m";
  } else if (milliseconds >= 1000) {
    // Convert to seconds
    return (milliseconds / 1000).toFixed(2) + " s";
  } else {
    // Display milliseconds
    return milliseconds + " ms";
  }
}

function getTimeFromTimestamp(dateString) {
  var dateObject = new Date(dateString);
  var localTime = dateObject.toLocaleTimeString();
  var milliseconds = dateObject.getMilliseconds();
  localTime = localTime + "." + milliseconds;
  return localTime;
}
// add or update the row in the table
var selectedRowIntId = null;

function addOrUpdateApiRow(data) {
  const { request, response, id, type } = data;
  if (type !== 'response' && type !== 'request') {
    return;
  }

  const { uri, method, timestamp } = request;


  const { statusCode = "_", duration = "Pending" } = response;
  let newNode = document.createElement('tr');

  newNode.className = 'api_row';
  newNode.id = "api_row_" + id;
  // if type is request then add new row else update the row
  if (type === 'response') {
    newNode = document.getElementById("api_row_" + id) ?? newNode;
  }
  // adding onclick event to the row
  newNode.onclick = function () {
    console.log('clicked');
    renderRightSideContent(data);
    handelModelOpenIfMobile();

  }
  // if the row is selected then render the overview table with the updated data automatically
  if (selectedRowIntId === id) {
    renderRightSideContent(data);
  }
  var style = '';
  if (statusCode >= 400) {
    style = 'color:#FFB4AB';
  }

  const rowHtml = `
              <td>${method}</td>
              <td>${uri}</td>
              <td style="${style}">${statusCode}</td>
              <td>${convertMilliseconds(duration)}</td>
              <td>${getTimeFromTimestamp(timestamp)}</td>
  `;
  newNode.innerHTML = rowHtml;
  const table = document.getElementById('api_body');
  table.appendChild(newNode);
}
function clearTable() {
  const table = document.getElementById('api_body');
  table.innerHTML = '';
}


var isConnected = false;
var tryCount = 0;

function handleAutoReconnect() {
  if (!isConnected && tryCount < 20) {
    console.log('Reconnecting... ');
    getIpAddressAndConnectWs();
    setTimeout(() => {
      handleAutoReconnect();
    }, 1000 + (tryCount * 1500));
    tryCount++;
  }
}

function addLogger(data) {
  const { message, logType, id, type, timestamp } = data;
  if (type == 'log') {
    let newNode = document.createElement('div');
    let timeStampNode = document.createElement('div');
    timeStampNode.className = 'log-time';
    newNode.id = "log_" + id;
    if (logType === 'error') {
      newNode.className = 'log-error';
    } else {
      newNode.className = 'log';
    }
    newNode.innerHTML = message;
    timeStampNode.innerHTML = getTimeFromTimestamp(timestamp);
    newNode.appendChild(timeStampNode);
    const logBox = document.getElementById('logger');
    logBox.appendChild(newNode);
  }
}


function onNewData(data) {
  addOrUpdateApiRow(data);
  addLogger(data);
  
}

function listenToWebsocket(uri) {
  // Establishing a WebSocket connection
  const socket = new WebSocket(uri);

  // Listening to connection open event
  socket.addEventListener('open', (event) => {
    isConnected = true;
    tryCount = 0;
    console.log('WebSocket connection opened:', event);
    document.getElementById('online_status').style.backgroundColor = "#28a745"
  });

  // Listening to connection error event
  socket.addEventListener('error', (error) => {
    console.error('WebSocket error:', error);
  });

  // Listening to connection close event
  socket.addEventListener('close', (event) => {
    isConnected = false;
    console.log('WebSocket connection closed:', event);
    document.getElementById('online_status').style.backgroundColor = "#E06C75";
    handleAutoReconnect();
  });

  // Listening to incoming messages
  socket.addEventListener('message', (event) => {
    const data = JSON.parse(event.data);
    console.log('Received message:', data);
    onNewData(data);
    // handleNewReuqest(data);
    // Handle the incoming data as needed
  });



  // Sending a sample message
  const sendMessage = () => {
    const message = { type: 'chat', content: 'Hello, WebSocket!' };
    socket.send(JSON.stringify(message));
  };
}

function handleNewReuqest(data) {
  const apiBox = document.getElementById('api-list-box');
  const newNode = document.createElement('div');
  const { request } = data;
  const { uri, method } = request;
  newNode.innerHTML = `<div class="api-list-item">${method} ${uri}</div>`;
  apiBox.appendChild(newNode);
}


function dragUi() {
  var dragger = document.querySelector('.content_dragger');
  var left = document.querySelector('.content_left');
  var right = document.querySelector('.content_right');
  var isDragging = false;

  const screenWidth = window.screen.availWidth;
  const screenHeight = window.screen.availHeight;

  const isMobile = screenWidth < 768;

  left.style.height = '100%';
  right.style.height = '100%';
  if (isMobile) {
    dragger.style.display = 'none';
    left.style.width = '100%';
    right.style.display = 'none';
    return;
  }

  left.style.width = screenWidth / 2 + 'px';
  right.style.width = screenWidth / 2 + 'px';


  dragger.addEventListener('mousedown', function (e) {
    isDragging = true;
  });
  document.addEventListener('mousemove', function (e) {
    if (!isDragging) return;
    const screenWidth = window.screen.availWidth;
    var x = e.clientX;
    var rect = dragger.getBoundingClientRect();
    var leftWidth = x;
    left.style.width = leftWidth + 'px';
    right.style.width = (screenWidth - leftWidth) + 'px';
  });

  document.addEventListener('mouseup', function (e) {
    isDragging = false;
  });
}

// --- tab ----
window.showTab = function (tabId) {
  // Hide all tab contents
  var tabContents = document.querySelectorAll('.tab-content');
  var tabList = document.querySelectorAll('.tab');
  tabList.forEach(function (tab) {
    tab.children[0].classList.remove('active');
  });
  tabContents.forEach(function (tabContent) {
    tabContent.classList.remove('active');
  });

  // Show the selected tab content
  tabList[tabId].children[0].classList.add('active')

  var selectedTab = tabContents[tabId];
  if (selectedTab) {
    selectedTab.classList.add('active');

    // Scroll to the selected tab with smooth animation
    selectedTab.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
}

// render the right side content

function renderRightSideContent(data) {
  showTab(0);
  selectedRowIntId = data.id;
  renderOverviewTable(data);
  renderHeaders(data);
  renderRequest(data);
  renderResponseBody(data);
  document.getElementById('copy-container').style.display = 'block';
  document.getElementById('curl_text').innerHTML = createCurlCommand(data);
}
function clearRightSideContent() {
  document.getElementById('overview_table').innerHTML = '';
  document.getElementById('response-header-body').innerHTML = '';
  document.getElementById('request-header-body').innerHTML = '';
  document.getElementById('tab3').innerHTML = '';
  document.getElementById('tab4').innerHTML = '';
  document.getElementById('copy-container').style.display = 'none';
  document.getElementById('curl_text').innerHTML = '';
}

// overview table render
function renderOverviewTable(data) {
  const { request, response, id, type } = data;
  const { uri, method, timestamp } = request;

  const { statusCode = "_", duration = "Pending" } = response;
  const htmlString = `
      <tbody style="border: none;" >
                    <tr style="border: none;">
                      <td class="overview_view_table_td">Request uri: </td>
                      <td class="overview_view_table_td">${uri}</td>
                    </tr>
                    <tr>
                      <td class="overview_view_table_td">Method</td>
                      <td class="overview_view_table_td">${method}</td>
                    </tr>
                    <tr>
                      <td class="overview_view_table_td">Status</td>
                      <td class="overview_view_table_td">${statusCode}</td>
                    </tr>
                    <tr>
                      <td class="overview_view_table_td">Duration</td>
                      <td class="overview_view_table_td">${convertMilliseconds(duration)}</td>
                    </tr>
                    <tr>
                      <td class="overview_view_table_td">Timestamp</td>
                      <td class="overview_view_table_td">${getTimeFromTimestamp(timestamp)}</td>
                  </tbody>
      `;
  document.getElementById('overview_table').innerHTML = htmlString;
}

// render headers section
const renderSpecificHeader = (headers) => {
  if (!headers) {
    return '';
  }
  const content = Object.keys(headers).map((key) => {
    return `<tr >
    <td class="overview_view_table_td">${key}</td>
    <td class="overview_view_table_td">${headers[key]}</td>
    </tr>`;
  });
  return `<table style="border: none;">
        <tbody>
          ${content.join('')}
        </tbody>
      </table>`;

};

function renderHeaders(data) {
  const { request, response, id, type } = data;
  const { headers: requestHeaders } = request;
  const { headers: responseHeaders } = response;
  document.getElementById('response-header-body').innerHTML = renderSpecificHeader(responseHeaders);
  document.getElementById('request-header-body').innerHTML = renderSpecificHeader(requestHeaders);
}


function renderRequest(data) {
  const { request, response, id, type } = data;
  const { data: requestData } = request;
  const tab3 = document.getElementById('tab3');
  tab3.innerHTML = '';

  // hide the tab if request is get
  if (request.method === 'GET') {
    document.getElementById('request_tab').style.display = 'none';
  } else {
    document.getElementById('request_tab').style.display = 'block';
  }

  if (requestData) {
    if (requestData['type'] === 'form-data') {
      console.log(requestData);
      tab3.innerHTML = requestData['result'].replaceAll("\n", "<br>");
    } else {
      var formatter = new JSONFormatter(requestData, 1, { theme: 'dark' });
      tab3.appendChild(formatter.render());
    }
  }
}

function renderResponseBody(dataObj) {
  const { response } = dataObj;
  const { data } = response;
  const tab4 = document.getElementById('tab4');
  tab4.innerHTML = '';


  if (data) {
    document.getElementById('response_tab').style.display = 'block';

    // if (typeof data !== 'object') {
    //   try{
    //     data = JSON.parse(data);
    //   }catch(e){}
    // }
    var formatter = new JSONFormatter(data, 1, { theme: 'dark' });
    let newNode = document.createElement('div');
    newNode.innerHTML = `hello athul`;
    tab4.appendChild(formatter.render());
    // } else {
    //   tab4.innerHTML = data;
    // }
  } else {
    document.getElementById('response_tab').style.display = 'none';
  }
}



function createCurlCommand(data) {
  const { request, response, id, type } = data;
  const { uri, method, headers, data: requestData } = request;
  const { data: responseData } = response;
  const headerString = Object.keys(headers).map((key) => {
    return `\n--header '${key}: ${headers[key]}'`;
  }).join(' ');

  var bodyString = '\n';
  if (requestData) {
    if (requestData['type'] === 'form-data') {
      bodyString += requestData['curlStr'];
    } else {
      bodyString = `--data-raw '${JSON.stringify(requestData)}'`;
    }
  }

  const curlCommand = `curl -X ${method} ${uri} ${headerString} ${bodyString}`;
  return curlCommand;

}

const copyToClipboard = async (id) => {
  try {
    const element = document.getElementById(id);
    await navigator.clipboard.writeText(element.textContent);
    console.log("Text copied to clipboard!");
    // Optional: Display a success message to the user
  } catch (error) {
    console.error("Failed to copy to clipboard:", error);
    // Optional: Display an error message to the user
  }
};

function handelModelOpenIfMobile() {
  const screenWidth = window.screen.availWidth;
  if (screenWidth < 768) {
    var right = document.querySelector('.content_right');
    // document.getElementById('modal-content-id').innerHTML='sghfgbdhshbg hdsfbghdsfj<br> sdfno';
    right.style.display = 'block';
    document.getElementById('modal-content-id').appendChild(right);

    $('#myModal').modal('show')
  }
}

function closeModal() {
  $('#myModal').modal('hide')
}

function closeNotification() {
  document.getElementById('notification').style.display = 'none';
}

function clearLogger() {
  document.getElementById('logger').innerHTML = '';
}



function onClearButtonClick() {
  clearTable();
  clearRightSideContent();
  clearLogger();
}

function appBarBtn(index) {
  const btnIds = ["network_btn", "log_btn"];
  const contentIds = ["api_logger", "logger",];
  for (let i = 0; i < btnIds.length; i++) {
    document.getElementById(btnIds[i]).classList.remove('my-btn-selected');
    document.getElementById(contentIds[i]).style.display = 'none';
  }
  document.getElementById(btnIds[index]).classList.add('my-btn-selected');

  if (index == 0) {
    document.getElementById(contentIds[index]).style.display = 'flex';
  } else {
    document.getElementById(contentIds[index]).style.display = 'block';
  }


}



function downloadHtml() {
  fetch(basePath+"/download", {
  }).then((res) => res.json()).
    then((data) => {
      console.log("download", data);
      const blob = new Blob([data.data], { type: 'text/html' });
      // const blob = new Blob([data], { type: 'application/octet-stream' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'index.html';
      a.click();
    }).catch((err) => { });
}

function renderInjectedData() {
  console.log('injectedData', injectedData);
  if (injectedData) {
    injectedData.forEach((item) => {
      onNewData(item)
    });
  }
}

var isTesting = false;

var hostname = window.location.hostname;
var basePath = "";  

if(isTesting){
  // need for local testing
   hostname = "localhost"; 
   basePath = "http://" + hostname + ":3001"; 
}



function getIpAddressAndConnectWs() {

  fetch(basePath+"/ip", {
  }).then((res) => res.json()).then((data) => {
    document.getElementById('ip_address').innerHTML =data.shareUrl;
    document.getElementById('ws_port').innerHTML = data.wsPort;
    if (hostname === 'localhost' && tryCount < 2) {
      document.getElementById('notification').style.display = 'block';
    }
    const ws = `ws://${hostname}:${data.wsPort}`;

    fetch(basePath+"/history", {
    }).then((res) => res.json()).
      then((data) => {
        data.forEach((item) => {
          onNewData(item)
        });
        listenToWebsocket(ws);

      }).
      catch((err) => { });

  });
}''';
