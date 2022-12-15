# 建立自己的ERC20代幣
### tags:`作品說明`  
建立ERC20智能合約，包含建立(代幣名稱、代幣代號、鑄造、燒毀、轉帳、授權、查詢、事件)等...。
### tags: `ERC20函式使用`
* metedata(代幣名稱、代幣代號、代幣小數點位置):
  * name()=>代幣名稱
  * symbol()=>代幣代號
  * decimals()=>代幣小數點位置
* query
  * totalSupply()=>查詢代幣總發行量
  * balanceOf()=>查詢帳戶代幣餘額
  * allowance()=>查詢持有者給授權者，授權多少代幣
* transfer
  * transfer()=>轉帳
  * transferFrom()=>第三方轉帳
* approve
  * approve()=>持有者授權給第三者
* event
  * Transfer()=>轉帳事件
  * Approval()=>授權事件
