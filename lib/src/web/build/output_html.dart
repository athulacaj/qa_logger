final String htmlString = r'''<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"
    integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"
    crossorigin="anonymous"></script>

  <!-- json formator -->
  <script src="https://cdn.jsdelivr.net/npm/json-formatter-js@2.3.4/dist/json-formatter.umd.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/json-formatter-js@2.3.4/dist/json-formatter.min.css" rel="stylesheet">


  <link rel="stylesheet" href="./_support.css">

  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
  integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>

<!-- assets -->
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />

<body>
  <div id="notification" style="display:none;position: absolute;z-index: 1000;width: 100%;" class="alert alert-info" role="alert" data-bs-theme="dark">
    <button type="button" style="margin-left:auto;padding:0px 10px 2px 10px;display: inline;" 
    onclick="closeNotification()" class="close" data-dismiss="modal" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
    <span>Open this URL on devices connected to the same network:  </span>
    <span id="ip_address" style="margin-left: 10px; color: #fff;"></span>
  </div>

  <div class="container-fluid body-container">

    <!-- tool bar  -->
    <div style="padding:12px 0 0px 4px;">
      <button type="button" onclick="onClearButtonClick()" class="btn btn-outline-dark btn-sm my-btn-outline">
        <span class="material-symbols-outlined">block</span>
        <span style="margin-left: 6px;">clear</span>
      </button>
    </div>
    <div class="content">

      <div class="content_left">
        <div class="content_left_main" id="api-list-box">
          <!-- content for this -->
          <table class="my_table">
            <thead class="">
              <tr class="my_table_th_tr">
                <th scope="col">Method</th>
                <th scope="col">uri</th>
                <th scope="col">Status</th>
                <th scope="col">Duration</th>
                <th scope="col">Timestamp</th>
                <!-- Add more columns as needed -->
              </tr>
            </thead>
            <tbody id="api_body" class="my_table_body">
              <!-- <tr>
                <td>GET</td>
                <td>https://stage.medisensehealthcare.com:3007/api/v1/customer/610/language?is_home=false</td>
                <td>200</td>
                <td>366 ms</td>
                <td>11.28.38.134</td>
              </tr> -->
              <!-- Add more rows as needed -->
            </tbody>
          </table>
          <!-- end of content -->
        </div>
        <div class="content_dragger">||</div>
      </div>
      <div id="content_right_id" class="content_right">
        <!-- content -->
        <!-- tab -->
        <div class="tabs-container">
          <div class="tab" onclick="showTab(0)"><span class="active">Overview</span></div>
          <div class="tab" onclick="showTab(1)"><span>Headers</span></div>
          <div class="tab" onclick="showTab(2)" id="request_tab" ><span>Request</span></div>
          <div class="tab" onclick="showTab(3)" id="response_tab" ><span>Response</span></div>
        </div>
        <div class="tab-view">
          <div id="tab1" class="tab-content active">
            <table style="border: none;" id="overview_table">

            </table>
            <br />
            <div id="copy-container" class="copy-container-class" style="position:relative;">
              <!-- Your text goes here -->
              <samp id="curl_text" class="curl_box"></samp>
              <button id="copy_btn" class="copy-button" title="" data-original-title="Copy to clipboard"
                onclick="copyToClipboard('curl_text')">Copy</button>
            </div>
          </div>


          <div id="tab2" class="tab-content">
            <div class="accordion" id="accordionExample" data-bs-theme="dark">
              <div class="accordion-item accordion-without-theme">
                <h2 class="accordion-header accordion-without-theme">
                  <button class="accordion-button accordion-without-theme" type="button" data-bs-toggle="collapse"
                    data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                    Response Headers
                  </button>
                </h2>
                <div id="collapseOne" class="accordion-collapse collapse" data-bs-parent="#accordionExample">
                  <div id="response-header-body" class="accordion-body">
                  </div>
                </div>
              </div>
              <div class="accordion-item accordion-without-theme">
                <h2 class="accordion-header accordion-without-theme">
                  <button class="accordion-button collapsed accordion-without-theme" type="button"
                    data-bs-toggle="collapse" data-bs-target="#collapseTwo" aria-expanded="false"
                    aria-controls="collapseTwo">
                    Request Headers
                  </button>
                </h2>
                <div id="collapseTwo" class="accordion-collapse collapse show" data-bs-parent="#accordionExample">
                  <div id="request-header-body" class="accordion-body">
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div id="tab3" class="tab-content">
            <!-- request body -->

          </div>
          <div id="tab4" class="tab-content">
            <!-- response body -->
          </div>
        </div>
        <!-- tab -->


      </div>
    </div>
  </div>
  <!-- modal -->
  <div id="myModal" class="modal fade bd-example-modal-lg " data-bs-theme="dark" tabindex="-1" role="dialog"
    aria-labelledby="myLargeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <div class="modal-content" id="modal-content-id">
        <div class="modal-header" style="padding: 5px;">
          <button type="button" style="margin-left:auto;padding:0px 10px 2px 10px;" onclick="closeModal()" class="close"
            data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>

      </div>
    </div>
  </div>
  <!-- --- modal end --- -->




  <script src="./_support.js"></script>
</body>

</html>''';