Important info about the files included in the STIG.zip file.

*** Two versions of the STIG are available.  The Unclassified version excludes IAVM information.  The FOUO version with IAVM information is available through a PKI enabled link. ***


This package contains files for manual review of the STIG and other supporting documents.

The following files are included.  The file names listed below are generic; the actual file names will be specific to the technology and checklist release.

STIG_Overview.pdf – This file will contain the overview and background information, as well as screen captures, network diagrams, and other important information that could not be stored in the XML file.

STIG_Revision_History.pdf - This file contains the history of changes to the STIG.

STIG_Application_Restrictions_policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the " Application Restrictions Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Application_Restrictions_policy.mobileconfig' and removed with 'sudo profiles -D'.

STIG_Bluetooth_Policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the "Bluetooth Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Bluetooth_Policy.mobileconfig' and removed with 'sudo profiles -D'.

STIG_Custom_Policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the "Custom Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Custom_Policy.mobileconfig' and removed with 'sudo profiles -D'.

STIG_Disable_iCloud_Policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the "Disable iCloud Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Disable_iCloud_Policy' and removed with 'sudo profiles -D'.

STIG_Login_Window_Policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the "Login Window Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Login_Window_Policy.mobileconfig' and removed with 'sudo profiles -D'.

STIG_Passcode_Policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the "Passcode Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Passcode_Policy.mobileconfig' and removed with 'sudo profiles -D'. Updates to password restrictions must be thoroughly evaluated in a test environment. Mistakes in configuration may block password change and local user creation operations as well as lock out all local users, including administrators.

STIG_Restrictions_Policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the "Restrictions Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Restrictions_Policy.mobileconfig' and removed with 'sudo profiles -D'.

STIG_Security_Privacy_Policy.mobileconfig - This file contains a configuration profile suitable for use with the Apple OS X STIG when it calls for the "Security Privacy Policy" configuration profile. It can be applied to a system with 'sudo profiles -I -F STIG_Security_Privacy_Policy.mobileconfig' and removed with 'sudo profiles -D'.


The following files are for manually viewing the STIG in a browser.   They need to be extracted to same directory for use.

Manual_STIG.xml – This is the STIG XML file that contains the manual check procedures.

STIG_unclass.xsl – This is a transformation file that will allow the XML to be presented in a “human friendly” format.

DoD-DISA-logos-as-JPEG.jpg - Contains logos used by STIG.xsl.