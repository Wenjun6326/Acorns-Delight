package com.acorndelight;

import net.fabricmc.fabric.api.creativetab.v1.FabricCreativeModeTab;

import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.core.registries.Registries;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.ResourceKey;
import net.minecraft.world.item.CreativeModeTab;
import net.minecraft.world.item.ItemStack;

/**
 * A dedicated creative tab for the mod.
 *
 * <p>26.1 made {@code CreativeModeTabs}' tab keys private, so there is no supported way to append
 * to a specific vanilla tab by key anymore; a mod-owned tab is the stable approach. Items placed in
 * a creative tab are also reachable through the search tab, so nothing is hidden from players.
 */
public final class ModCreativeTabs {
	private ModCreativeTabs() {
	}

	public static final ResourceKey<CreativeModeTab> ACORNS_DELIGHT_TAB_KEY = ResourceKey.create(
			Registries.CREATIVE_MODE_TAB, AcornsDelight.id("acorns_delight"));

	public static final CreativeModeTab ACORNS_DELIGHT_TAB = FabricCreativeModeTab.builder()
			.icon(() -> new ItemStack(ModItems.ACORN))
			.title(Component.translatable("itemGroup.acorn_delight.acorns_delight"))
			.displayItems((parameters, output) -> {
				output.accept(ModItems.ACORN);
				output.accept(ModItems.ACORN_JAM);
			})
			.build();

	public static void initialize() {
		Registry.register(BuiltInRegistries.CREATIVE_MODE_TAB, ACORNS_DELIGHT_TAB_KEY, ACORNS_DELIGHT_TAB);
	}
}
