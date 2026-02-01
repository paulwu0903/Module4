module game::bsui;

// === Imports ===
use sui::{
    coin_registry::{ Self , CoinRegistry, Currency},
    transfer::{ Receiving },
    coin:: { Coin, TreasuryCap },
};

// === Structs ===
// OTW
public struct BSUI has drop{}

fun init(
    otw: BSUI,
    ctx: &mut TxContext,
){

    let (initializer, treasury_cap) = coin_registry::new_currency_with_otw(otw, 9, b"BSUI".to_string(), b"Grow Coin".to_string(), b"Grow Coin".to_string(), b"https://grow.coin.xyz".to_string(), ctx);
    let metadata_cap = initializer.finalize(ctx);

    transfer::public_transfer(metadata_cap, ctx.sender());
    transfer::public_transfer(treasury_cap, ctx.sender());
}

public fun register(
    registry: &mut CoinRegistry,
    currency: Receiving<Currency<BSUI>>,
    ctx: &mut TxContext,
){
    registry.finalize_registration<BSUI>(currency, ctx);
}

#[allow(lint(self_transfer))]
public fun mint(
    cap: &mut TreasuryCap<BSUI>,
    amount: u64,
    ctx: &mut TxContext,
){
    let demo_coin = cap.mint(amount, ctx);
    transfer::public_transfer(demo_coin, ctx.sender());
}

public fun burn(
    cap: &mut TreasuryCap<BSUI>,
    demo_coin: Coin<BSUI>,
){
    cap.burn(demo_coin);
}