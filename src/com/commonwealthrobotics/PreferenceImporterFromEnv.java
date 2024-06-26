package com.commonwealthrobotics;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.Scanner;

import org.eclipse.ui.IStartup;
import org.eclipse.ui.PlatformUI;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.core.runtime.preferences.IPreferencesService;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;
import org.osgi.service.prefs.Preferences;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.ui.PlatformUI;

public class PreferenceImporterFromEnv extends AbstractUIPlugin implements IStartup {
	public static final String PLUGIN_ID = "com.commonwealthrobotics.PreferenceImporterFromEnv";

	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
		log("PreferenceImporterFromEnv started");
	}

	public static void promptForRestart() {
		Display.getDefault().asyncExec(() -> {
			Shell shell = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();
			boolean restart = MessageDialog.open(MessageDialog.QUESTION, shell, "Restart Required",
					"Your one time workspace configurations have been applied. Do you want to restart now?", SWT.NONE);
			if (restart) {
				PlatformUI.getWorkbench().restart();
			}
		});
	}
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
			
			Preferences preferences = InstanceScope.INSTANCE.getNode("org.eclipse.jdt.core");
			String compilerVersion = preferences.get("org.eclipse.jdt.core.compiler.compliance", "UNKNOWN");
			String targetCompliance = "1.8";
			try {
				Scanner scanner = new Scanner(epfFile);
				// now read the file line by line...
				while (scanner.hasNextLine()) {
					String line = scanner.nextLine();
					if(line.contains("org.eclipse.jdt.core.compiler.compliance")) {
						targetCompliance=line.split("=")[1];
						scanner.close();
						break;
					}
				}
				scanner.close();
			} catch (FileNotFoundException e) {
				// handle this
			}
			if(!compilerVersion.contains(targetCompliance)) {
				FileInputStream inputStream = new FileInputStream(epfFile);
				
				service.importPreferences(inputStream);
				inputStream.close();
	
				// Force save of imported preferences
				IEclipsePreferences prefs = InstanceScope.INSTANCE.getNode("org.eclipse.ui.workbench");
				prefs.flush();
				String x = "Loaded Preferences from "+epfFile.getAbsolutePath();
				log(x);
				promptForRestart();
			}else {
				log("Preferences are already set, JVM version is "+compilerVersion);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void log(String x) {
		System.out.println(x);
		getLog().log(new Status(IStatus.INFO, PreferenceImporterFromEnv.class, x));
	}
}