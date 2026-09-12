package com.acorndelight;

import net.fabricmc.api.ModInitializer;

import net.minecraft.resources.Identifier;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Acorn's Delight — a small Farmer's Delight add-on that adds acorns and acorn jam.
 *
 * <p>Targets Minecraft 26.1.x on Fabric. Note that 26.1 is the first unobfuscated Minecraft
 * release, so this mod is written against Mojang's official names.
 */
public class AcornsDelight implements ModInitializer {
	public static final String MOD_ID = "acorn_delight";

	public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

	/**
	 * Creates an {@link Identifier} in this mod's namespace.
	 */
	public static Identifier id(String path) {
		return Identifier.fromNamespaceAndPath(MOD_ID, path);
	}

	@Override
	public void onInitialize() {
		// Registration order matters: items first (the creative tab's icon and contents
		// reference them), then the creative tab, then the loot table hooks.
		ModItems.initialize();
		ModCreativeTabs.initialize();
		ModLootTables.initialize();

		LOGGER.info("Acorn's Delight loaded — acorns now drop from oak leaves.");
	}
}
