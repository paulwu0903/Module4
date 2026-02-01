/** Hot Potato 燙手山芋
 * Def: 當操作行為需要求在同一個 Transaction 完成，就會使用  Hot Potato。
 * Ex: Flash Loan
 * 格式： 不含任何 ability 的 Struct
 * Ex: public struct Receipt {}
 * 補充：能消除 Hot Potato 的方式 ? 1. UnWrap, 2. Transfer 3. Wrap into another object ?
 * 
 * 
 * Programmable Transaction Block (PTB)
 * 
**/

module module_4::flash_loan;

// == Imports ===
use sui::{
    coin::{ Coin },
    balance::{ Self, Balance},
};


// === Structs ===
public struct Pool<phantom T> has key{
    id: UID,
    balance: Balance<T>,
}

public struct FlashLoanAdminCap has key, store  {
    id: UID,
}

public struct Receipt<phantom T>{
    borrowed_amount: u64, 
}

// === Errors ===
const ECoinNotEnough: u64 = 0;
const ERepayValueNotEnough: u64 = 1;

// === Constants ===
const FLASH_LOAN_FEE: u64 = 10; // 0.1 %, denominator: 10_000

// === Init Functions ===
fun init(ctx: &mut TxContext){
    let admin_cap = FlashLoanAdminCap{
        id: object::new(ctx),
    };

    transfer::public_transfer(admin_cap, ctx.sender());
}

// === Admin Functions ===
public fun add_coin<T>(
    self: &mut Pool<T>,
    _: &FlashLoanAdminCap,
    coin: Coin<T>,
){
    self.balance.join(coin.into_balance());
}

public fun new_pool<T>(
    _: &FlashLoanAdminCap,
    ctx: &mut TxContext,
){  
    let pool = Pool<T>{
        id: object::new(ctx),
        balance: balance::zero<T>(),
    };

    transfer::share_object(pool);
}

// === Public Functions ===
public fun flash_loan<T>(
    self: &mut Pool<T>,
    amount: u64,
    ctx: &mut TxContext,
):( Coin<T>, Receipt<T> ){
    if ( amount > self.balance.value()){
        abort ECoinNotEnough
    };
    let borrowed_balance = self.balance.split(amount);
    let receipt = Receipt<T>{
        borrowed_amount: borrowed_balance.value() * ((10_000 + FLASH_LOAN_FEE) / 10_000),
    };

    (borrowed_balance.into_coin(ctx), receipt)
}

public fun repay_flash_loan<T>(
    self: &mut Pool<T>,
    receipt: Receipt<T>,
    coin: Coin<T>,
){
    if (coin.value() != receipt.borrowed_amount ){
        abort ERepayValueNotEnough
    };
    let Receipt{
        borrowed_amount: _,
    } = receipt;

    self.balance.join(coin.into_balance());
}


//SUI CLI PTB:
// 語法： sui client ptb 
// 地址需要加上 「 @ 」符號。
// --assign <NAME> <VALUE> :  將<VALUE> 綁定到 <NAME> 變數
// --transfer-objects "<[OBJECTS]>" <TO>： 轉移 Object ，注意 <[OBJECTS]> 是 Array
// --split-coins <COIN> "<[AMOUNT]>" : Coin 切割操作。
// --merge-coins <INTO_COIN> "<[COIN OBJECTS]>":  Coin 合併操作
// --move-call <PACKAGE::MODULE::FUNCTION> "<TYPE>" <FUNCTION_ARGS>: 執行合約 Function，注意： <TYPE> 需要用 「""」包起來， Ex: "0x2::sui::SUI"
// --dry-run: 試跑，但不會真的發生在鏈上。