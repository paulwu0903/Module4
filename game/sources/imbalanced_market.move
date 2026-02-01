module game::imbalanced_market;

// === Imports ===
use sui::{
    balance::{ Self, Balance },
    coin:: { Coin },
};

// === Errors ===
const ECoinBNotEnough: u64 = 0;
const ECoinANotEnough: u64 = 1;

// === Constants ===
const COIN_A_TO_COIN_B_RATE: u64 = 10_000;
const COIN_B_TO_COIN_A_RATE:u64 = 10_300;
const BPS_BASE: u64 = 10_000;


// === Structs ===

public struct ImbalancedMarket<phantom CoinA, phantom CoinB> has key {
    id: UID,
    balance_a: Balance<CoinA>,
    balance_b: Balance<CoinB>,
}

public struct ImbalancedMarketCap has key, store {
    id: UID,
}

// === Init ===
fun init(ctx: &mut TxContext){
    let market_cap = ImbalancedMarketCap{
        id: object::new(ctx),
    };

    transfer::public_transfer(market_cap, ctx.sender());
}

// === Admin Functions ===
public fun new_market<CoinA, CoinB>(
    _: &ImbalancedMarketCap,
    ctx: &mut TxContext
):ImbalancedMarket<CoinA, CoinB>{
    let market = ImbalancedMarket<CoinA, CoinB>{
        id: object::new(ctx),
        balance_a: balance::zero<CoinA>(),
        balance_b: balance::zero<CoinB>(),
    };
    market
}

public fun share_market<CoinA, CoinB>(
    market: ImbalancedMarket<CoinA, CoinB>,
){
    transfer::share_object(market);
}


public fun add_balance_a<CoinA, CoinB>(
    self: &mut ImbalancedMarket<CoinA, CoinB>,
    _: &ImbalancedMarketCap,
    coin: Coin<CoinA>,
){
    self.balance_a.join(coin.into_balance());
}

public fun add_balance_b<CoinA, CoinB>(
    self: &mut ImbalancedMarket<CoinA, CoinB>,
    _: &ImbalancedMarketCap,
    coin: Coin<CoinB>,
){
    self.balance_b.join(coin.into_balance());
}

// === Public Functions ===
public fun swap_a2b<CoinA, CoinB>(
    self: &mut ImbalancedMarket<CoinA, CoinB>,
    coin: Coin<CoinA>,
    ctx: &mut TxContext,
): Coin<CoinB>{
    let coin_b_amount = coin.value() * COIN_A_TO_COIN_B_RATE / BPS_BASE;
    if (self.balance_b.value() < coin_b_amount){
        abort ECoinBNotEnough
    };
    self.balance_a.join(coin.into_balance());
    self.balance_b.split(coin_b_amount).into_coin(ctx)
}

public fun swap_b2a<CoinA, CoinB>(
    self: &mut ImbalancedMarket<CoinA, CoinB>,
    coin: Coin<CoinB>,
    ctx: &mut TxContext,
): Coin<CoinA>{
    let coin_a_amount = coin.value() * COIN_B_TO_COIN_A_RATE / BPS_BASE;
    if (self.balance_a.value() < coin_a_amount){
        abort ECoinANotEnough
    };
    self.balance_b.join(coin.into_balance());
    self.balance_a.split(coin_a_amount).into_coin(ctx)
}
