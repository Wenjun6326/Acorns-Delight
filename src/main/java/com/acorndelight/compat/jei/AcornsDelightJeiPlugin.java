package com.acorndelight.compat.jei;

import com.acorndelight.AcornsDelight;

import mezz.jei.api.IModPlugin;
import mezz.jei.api.JeiPlugin;

import net.minecraft.resources.Identifier;

/**
 * JEI integration.
 *
 * <p>Acorn Jam is made with an ordinary shaped crafting recipe, which JEI already understands, so
 * JEI shows the recipe without any help from us. This plugin exists to declare the mod to JEI and
 * to give future custom categories (cooking-pot style recipes, and so on) a place to live.
 *
 * <p>The class is driven by the {@code jei_mod_plugin} entrypoint in {@code fabric.mod.json}; if JEI
 * is not installed the entrypoint is simply never loaded.
 */
@JeiPlugin
public class AcornsDelightJeiPlugin implements IModPlugin {
	public static final Identifier PLUGIN_UID = Identifier.fromNamespaceAndPath(AcornsDelight.MOD_ID, "jei_plugin");

	@Override
	public Identifier getPluginUid() {
		return PLUGIN_UID;
	}
}
