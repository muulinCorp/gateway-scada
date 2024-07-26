# Change Log
All notable changes to this project will be documented in this file.
 
## [1.0.3] - 2024-07-26

### Related service
- rubase_alert

### Changed
- 欄位timeRange，更改為time_range. 原本欄位發生schema和example不一致，現在同一更改為time_range,影響的api如下：
    - POST /web/warning/setting/
    - GET /web/warning/setting/{ID}
    - PUT /web/warning/setting/{ID}
    - GET /web/warning/setting
