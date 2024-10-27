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
		String epfPath = System.getenv("ECLIPSE_PREFERENCE_FILE");
		if (epfPath != null && !epfPath.isEmpty()) {
			epfPath=epfPath.strip();
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
			
			boolean newConf=false;
			try {
				Scanner scanner = new Scanner(epfFile);
				// now read the file line by line...
				while (scanner.hasNextLine()) {
					String line = scanner.nextLine();
					if(line.startsWith("/")) {
						//System.out.println("\nChecking Configuration "+line);
						line=line.substring(1);
						String type  = line.substring(0, line.indexOf("/"));
						String rest = line.substring(line.indexOf("/")+1);
						String node = rest.substring(0, rest.indexOf("/"));
						String kevalue = rest.substring(rest.indexOf("/")+1);
						String key =kevalue.substring(0, kevalue.indexOf("="));
						String value = kevalue.substring(kevalue.indexOf("=")+1);
						Preferences preferences = InstanceScope.INSTANCE.getNode(node);
						String data = preferences.get(key, "UNKNOWN");
						if(value.length()==0) {
							continue;
						}
						if(type.contentEquals("configuration")) {
							continue;
						}
						// if either the values are files, just skip the check because of escape values not linig up
						try {
							if(new File(value).exists())
								continue;
						}catch(Throwable t) {
							//ignore
						}
						try {
							if(new File(data).exists())
								continue;
						}catch(Throwable t) {
							//ignore
						}
						if(key.endsWith("XML"))
							continue;// XML can not be checked like this
						if(value.startsWith("<?xml"))
							continue;//check for any xml content
						if(key.contentEquals("platformState"))
							continue;// this is always changing
						if(data.contentEquals(value)) {
							//System.out.println(key+" is set to "+value);
						}else {
							log(key+" is not set to "+value+" instead was found to be "+data);
							newConf=true;
							break;
						}
					}

				}
				scanner.close();
			} catch (FileNotFoundException e) {
				// handle this
			}
			if(newConf) {
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
				log("Preferences are all already set");
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void log(String x) {
		//System.out.println(x);
		getLog().log(new Status(IStatus.INFO, PreferenceImporterFromEnv.class, x));
	}
}