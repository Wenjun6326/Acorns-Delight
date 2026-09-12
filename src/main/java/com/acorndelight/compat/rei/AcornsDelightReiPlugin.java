package com.acorndelight.compat.rei;

import me.shedaniel.rei.api.client.plugins.REIClientPlugin;

/**
 * REI integration.
 *
 * <p>As with JEI, the Acorn Jam recipe is a plain shaped crafting recipe that REI already renders in
 * its crafting category, so no custom category is required. Registering this plugin makes the mod a
 * first-class REI participant and gives any later custom displays somewhere to be registered.
 *
 * <p>Driven by the {@code rei_client} entrypoint in {@code fabric.mod.json}; it is not loaded when
 * REI is absent.
 */
public class AcornsDelightReiPlugin implements REIClientPlugin {
	@Override
	public Class<REIClientPlugin> getPluginProviderClass() {
		return REIClientPlugin.class;
	}
}
