final String cssString = r'''
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box !important;
}

html {
    width: 100%;
    height: 100%;
    font-size: 16px;
    /* define variables */
    --background-color: #1B1B1F;
    --text-color: #C7C6CA;
    --border-color: #444750;
    --box-border-value: 2px solid #444750;
    --box-radius: 12px;
}

body {
    width: 100%;
    height: 100%;
    overflow: hidden;
    font-family: 'Roboto', sans-serif;
    font-size: 14px;
}

.body-container {
    background-color: var(--background-color);
    width: 100%;
    height: 100%;
    color: var(--text-color);
}

/* ----------- content ----------- */
.content {
    display: flex;
    width: 100%;
    height: calc(100% - 52px);
    padding: 10px 0;
}

.content_left {
    display: flex;
    overflow: hidden;
}

.content_left_main {
    /* background-color: #252B48; */
    width: 100%;
    overflow: auto;
}

.content_dragger {
    height: 100%;
    min-width: 14px;
    margin: auto;
    cursor: ew-resize;
    display: flex;
    justify-content: center;
    align-items: center;
}

.content_left_main,
.content_right {
    /* lioght white border */
    border: var(--box-border-value);
    border-radius: var(--box-radius);
}

.content-right {
    overflow: hidden;
    height: 100%;

}


@media screen and (max-width: 768px) {
    .content_right {
        display: none;
    }

}

/* ----------- content ----------- */

/* ----------- table -------------- */
.my_table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    border-bottom: var(--box-border-value);
}

/* .my_table>tbody>tr {
    max-height: 30px;
} */

.my_table>tbody>tr:nth-child(odd) {
    background-color: #303033;
}

.my_table>tbody>tr:nth-child(odd):hover {
    background-color: #484848;
}

.my_table>tbody>tr:nth-child(even):hover {
    background-color: #33333369;
}

.api_row {
    cursor: pointer;
}

.my_table_th_tr>th {
    position: sticky;
    top: 0;
}

.my_table_th_tr>th,
.my_table_th_tr>td,
.api_row>td {
    padding: 10px 10px;
    border-right: 2px solid #444750;
    /* Vertical border */
}


th {
    position: sticky;
    top: 0;
    background-color: var(--background-color);
}

.my_table>tbody>tr>td {
    text-align: end;
    padding: 8px 10px;
}

.my_table>tbody>tr>td:nth-child(1) {
    text-align: start;
}

.my_table>tbody>tr>td:nth-child(2) {
    max-lines: 1;
    white-space: nowrap;
    overflow: auto;
    max-width: 300px;
    cursor: all-scroll;
    text-align: start;
}

@media screen and (max-width: 768px) {
    .my_table>tbody>tr>td:nth-child(2) {
        max-width: 180px;
    }
}


.my_table>tbody>tr>td:nth-child(2)::-webkit-scrollbar {
    /* Hide the scrollbar for WebKit browsers */
    display: none;
}

.content_left_main::-webkit-scrollbar {
    width: 10px;
    height: 10px;
    background-color: var(--background-color);
}

.content_left_main::-webkit-scrollbar-thumb {
    background-color: #ffffff99;
    border-radius: 10px;
}

.content_left_main::-webkit-scrollbar-track {
    border-radius: 5px;
    width: 6px;
}


/* ----------- table -------------- */

/* ----------- tab -------------- */

.tabs-container {
    display: flex;
    justify-content: start;
}

.tab {
    cursor: pointer;
    padding: 14px;
    transition: background-color 0.3s;
}

.tab>span.active {
    padding-bottom: 10px;
    border-bottom: 3px solid #ccc;
}

.tab:hover {
    background-color: #29292D;
}

.tab-view {
    border-top: 1px solid #333;
    padding: 14px;
    overflow: auto;
    height: calc(100% - 52px);
}

.tab-content {
    display: none;
}


.tab-content.active {
    display: block;
}

/* ----------- tab -------------- */

/* -------- right side contents --------- */
.overview_view_table_td {
    min-width: 100px;
    padding: 4px;
    vertical-align: top;
    word-break: break-all;
}

/* -------- right side contents --------- */
.accordion-without-theme {
    color: var(--text-color) !important;
    background-color: transparent !important;
}


::-webkit-scrollbar {
    width: 10px;
    height: 10px;
    background-color: var(--background-color);
}

::-webkit-scrollbar-thumb {
    background-color: #ffffff99;
    border-radius: 10px;
}

::-webkit-scrollbar-track {
    border-radius: 5px;
    width: 6px;
}


/* json beauify */
.json-formatter-dark.json-formatter-row .json-formatter-string,
.json-formatter-dark.json-formatter-row .json-formatter-stringifiable {
    /* color: #D68D72 !important; */
    color: #d68d72e7 !important;
}

.json-formatter-constructor-name {
    color: #919094 !important;
}

.json-formatter-dark.json-formatter-row .json-formatter-key {
    color: #C586C0 !important;
}

/* ---- cyrl copy --------- */

.copy-container-class {
    /* width: 300px; */
    padding: 10px;
    padding-top: 36px;
    margin-bottom: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    overflow: hidden;
    position: relative;
    display: none;
}

.copy-button {
    position: absolute;
    top: 0;
    right: 0;
    cursor: pointer;
    /* background-color: #4CAF50; */
    /* color: #fff; */
    border: none;
    padding: 3px 20px;
    border-radius: 5px;
    background-color: #333;
    color: #fff;
}

.copy-button:hover {
    background-color: #919094;
}

.curl_box {
    padding: 4px 10px;
    word-break: break-all;
}

#myModal{
    height:100%;
    /* overflow: hidden; */
}

.modal-content {
    color: var(--text-color);
    min-height: 100%;
}

.modal-dialog {
    height: 100%;
}

.my-btn-outline {
    /* border-color: var(--text-color); */
    border-color: #444750;
    color: var(--text-color);
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
}

.my-btn-selected {
    color: var(--bs-btn-hover-color);
    background-color: var(--bs-btn-hover-bg);
    border-color: var(--bs-btn-hover-border-color);
}

/* log style section */
.log,
.log-error {
    padding: 8px;
    padding-top: 18px;
    margin: 6px;
    word-break: break-all;
    overflow: auto;
    max-height: 200px;
    /* background-color: #333; */
    /* border-radius: 12px; */
    border-bottom: var(--box-border-value);
    position: relative;
}

.log-time {
    /* light white color */
    color: #919094;
    top: -2px;
    position: absolute;
    right: 4px;
    font-size: 12px;
}

.log {
    /* blue color */
    color: #61AFEF;
}

.log-error {
    /* red color */
    color: #E06C75;
}

.logger_box {
    height: calc(100% - 52px);
    overflow-y: auto;
    display: none;
    border-top: 1px solid var(--text-color);
    margin-top: 16px;
}


.tool_bar {
    padding: 12px 0 6px 4px;
    display: flex;
    gap: 8px;
    color: #252830;
    align-items: center;
}
.toolbar_icon_label {
    margin-left: 6px;
    display: inline-block;
}
@media screen and (max-width: 768px) {
    .toolbar_icon_label {
        display: none;
    }

}

/* ----- online ------ */
.online_box {
    margin-left: auto;
}

.online_box {
    /*  red color initial */
    background-color: #E06C75;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    display: inline-block;
}''';
