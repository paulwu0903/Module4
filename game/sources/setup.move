module game::setup;

// === Imports ===
use game::{
    asui::{Self, ASUI}, 
    bsui::{Self, BSUI},
    imbalanced_market::{Self, ImbalancedMarketCap},
};

use sui::{
    transfer::{Receiving},
    coin_registry::{CoinRegistry, Currency},
    coin::{TreasuryCap},
};


// === Admin Functions ===
#[allow(lint(self_transfer))]
public fun setup(
    registry: &mut CoinRegistry,
    market_cap: &mut ImbalancedMarketCap,
    treasury_cap_asui: &mut TreasuryCap<ASUI>,
    treasury_cap_bsui: &mut TreasuryCap<BSUI>,
    currency_a: Receiving<Currency<ASUI>>,
    currency_b: Receiving<Currency<BSUI>>,
    ctx: &mut TxContext
){
    asui::register(registry, currency_a, ctx);
    bsui::register(registry, currency_b, ctx);
    let mut market = imbalanced_market::new_market<BSUI, ASUI>(market_cap, ctx);

    imbalanced_market::add_balance_a<BSUI, ASUI>(&mut market, market_cap, treasury_cap_bsui.mint(1_000_000_000_000_000_000, ctx));
    imbalanced_market::add_balance_b<BSUI, ASUI>(&mut market, market_cap, treasury_cap_asui.mint(1_000_000_000_000_000_000, ctx));

    let to_admin_bsui = treasury_cap_bsui.mint(1_000_000_000_000_000_000, ctx);
    let to_admin_asui = treasury_cap_asui.mint(1_000_000_000_000_000_000, ctx);

    transfer::public_transfer(to_admin_bsui, ctx.sender());
    transfer::public_transfer(to_admin_asui, ctx.sender());

    imbalanced_market::share_market(market);
}