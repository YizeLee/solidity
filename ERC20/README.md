# 建立自己的ERC20代幣
### tags:`作品說明`  
建立ERC20智能合約，包含建立(代幣名稱、代幣代號、鑄造、燒毀、轉帳、授權、查詢、事件)等...。
### tags: `ERC20函式介紹`
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
* mint
  * mint()=>鑄造代幣
* burn
  * burn()=>燃燒代幣
* event
  * Transfer()=>轉帳事件
  * Approval()=>授權事件
### tags: `ERC20函式個別說明`
* metedata(代幣名稱、代幣代號、代幣小數點位置):
  * name()=>代幣名稱
  * symbol()=>代幣代號
  * decimals()=>代幣小數點位置  
  >1. 部屬合約後，constructors()先建立代幣名稱(_name)、代幣代號(_symbol)。點選function name()、symbol()、decimals()，就能查詢代幣名稱、代幣代號。
  >2. 撰寫decimals()，因為ETH當初就是設定為18，我們延續這個傳統，也設定18。  
* query
  * totalSupply()=>查詢代幣總發行量
  >1. 在constructors()建立代幣的總發行量為多少。
  * balanceOf()=>查詢帳戶代幣餘額
  >1. 建立一個_balance 的mapping，只要輸入address就能對應該address有多少代幣。
  * allowance()=>查詢持有者給授權者，授權多少代幣
  
