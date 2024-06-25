package com.commonwealthrobotics;

import java.io.File;
import java.io.FileInputStream;
import org.eclipse.ui.IStartup;
import org.eclipse.ui.PlatformUI;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.core.runtime.preferences.IPreferencesService;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.plugin.AbstractUIPlugin;
public class PreferenceImporterFromEnv extends AbstractUIPlugin implements IStartup {
	@Override
	public void earlyStartup() {
		String epfPath = System.getenv("ECLIPSE_PREFERENCE_FILE").strip();
		if (epfPath != null && !epfPath.isEmpty()) {
			if(epfPath.contains("\"")) {
				epfPath = epfPath.replace("\"", "").strip();
			}
			File epfFile = new File(epfPath);
			if (epfFile.exists()) {
				log("EPF File Found at ECLIPSE_PREFERENCE_FILE "+epfPath);
				PlatformUI.getWorkbench().getDisplay().asyncExec(() -> {
					load(epfFile);
				});
			}else {
				log("Preference file does not exist "+epfPath);
			}
		}else {
			log("Preference file not provided via environment variable ECLIPSE_PREFERENCE_FILE");
		}
	}

	private void load(File epfFile) {
		try {
			IPreferencesService service = Platform.getPreferencesService();
			FileInputStream inputStream = new FileInputStream(epfFile);
			
			service.importPreferences(inputStream);
			inputStream.close();

			// Force save of imported preferences
			IEclipsePreferences prefs = InstanceScope.INSTANCE.getNode("org.eclipse.ui.workbench");
			prefs.flush();
			String x = "Loaded Preferences from "+epfFile.getAbsolutePath();
			log(x);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void log(String x) {
		System.out.println(x);
		getLog().log(new Status(IStatus.INFO, PreferenceImporterFromEnv.class, x));
	}
}