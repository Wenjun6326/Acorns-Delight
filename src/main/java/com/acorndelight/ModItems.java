package com.acorndelight;

import java.util.function.Function;

import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.core.registries.Registries;
import net.minecraft.resources.ResourceKey;
import net.minecraft.world.food.FoodProperties;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.component.Consumable;
import net.minecraft.world.item.component.Consumables;

/**
 * All items added by Acorn's Delight.
 */
public final class ModItems {
	private ModItems() {
	}

	/**
	 * Registers an item. In 26.1 the item's {@link ResourceKey} has to be assigned through
	 * {@link Item.Properties#setId(ResourceKey)} before the item is constructed.
	 */
	public static <T extends Item> T register(String name, Function<Item.Properties, T> itemFactory, Item.Properties settings) {
		ResourceKey<Item> itemKey = ResourceKey.create(Registries.ITEM, AcornsDelight.id(name));
		T item = itemFactory.apply(settings.setId(itemKey));
		Registry.register(BuiltInRegistries.ITEM, itemKey, item);
		return item;
	}

	/** A plain, inedible acorn. */
	public static final Item ACORN = register("acorn", Item::new, new Item.Properties());

	/**
	 * Acorn Jam: restores 4 hunger (nutrition) and 3.5 saturation.
	 *
	 * <p>26.1 converts the builder's saturation modifier into an absolute saturation value with
	 * {@code saturation = nutrition * modifier * 2}, so {@code 4 * 0.4375 * 2 == 3.5}.
	 */
	public static final FoodProperties ACORN_JAM_FOOD = new FoodProperties.Builder()
			.nutrition(4)
			.saturationModifier(0.4375f)
			.build();

	/** A bottled jam, so it is consumed like a drink (1.6s) rather than chewed like food. */
	public static final Consumable ACORN_JAM_CONSUMABLE = Consumables.defaultDrink()
			.consumeSeconds(1.6f)
			.build();

	public static final Item ACORN_JAM = register("acorn_jam", Item::new,
			new Item.Properties().food(ACORN_JAM_FOOD, ACORN_JAM_CONSUMABLE));

	/**
	 * Forces class initialisation so that every item is registered.
	 */
	public static void initialize() {
	}
}
