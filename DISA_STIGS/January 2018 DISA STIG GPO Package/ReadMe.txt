WARNING
-------

It must be noted that the Group Policy Objects (GPO) provided should be evaluated in a local, representative test environment before implementation within production environments. The extensive variety of environments makes it impossible to test these GPOs for all potential enterprise Active Directory and software configurations. For most environments, failure to test before implementation may lead to a loss of required functionality.

It is especially important to fully test with all GPOs against all Windows Operating Systems, internet browsers, specific and legacy applications which are targeted by each STIG GPO which are currently used in the environment.


INTRODUCTION
------------

This package contains ADMX template files, GPO backups exports, GPO reports, and WMI filter exports and STIG Checklist files. It is to provide enterprise administrators the supporting GPOs and related files to aid them in the deployment of GPOs within their enterprise to meet STIG settings. Administrators are expected to fully test GPOs in test environments prior to live production deployments.


MAINTENANCE
-----------

This package will be updated with each quarterly release of STIG updates. If a targeted STIG within package is released out of cycle, the package will be updated accordingly. Additional if a new STIG is targeted to provide a supporting GPO, the package will be updated to include GPO backup, GPO report, and checklist file and ADMX and WMI filter exports as required. 


USAGE
-----

This package is to be used to assist administrators implementing STIG settings within their environment. The administrator must fully test GPOs in test environments prior to live production deployments. The GPOs provided contain most applicable GPO STIG settings contained in STIG files. 

The GPO backups are located under the GPO directory in parent STIG directory. Administrators will be required to modify operating system GPOs to reflect the appropriate Enterprise Admins and Domain Admins groups for User Rights Assignments. The GPOs contain ADD YOUR ENTERPRISE ADMINS and ADD YOUR DOMAIN ADMINS text. These can be modified during import of GPO backups if a migration table is used or after import is complete. 

GPOs are split into computer configuration and user configuration were possible. Each GPO has the only the appropriate section enabled within the configured GPO. For example, a GPO identified as a Computer GPO the User Configuration section of GPO is disabled. 

The Office System 2013 and Office System 2016 GPOs contain the IE Security settings from each of the components because of GPO application and precedence.

The checklist files are located under the Checklist directory in parent STIG directory. The provided checklists were generated with DISA STIG Viewer 2.5.4. Each client and member server operating system checklists have 8 open items identified. These are the User Rights Assignment settings referencing Enterprise Admins, Domain Admins groups, and unknown SIDs. Additionally, the rename Administrator account and rename Guest account are open. The GPOs have modified account names; however, items were marked open to ensure administrator reviewed and modified to local configurations.
The Office components checklist will reflect 100%; however, the corresponding GPO do not contain Computer Configuration IE Security settings are configured within the appropriate Office Suite GPO.

The WMI Filter files are located under the WMI Filter directory in parent STIG directory. The provided WMI filter exports files are sample WMI filters that can be used to apply to the matching GPO to target the desired operating system or application.

The provided GPO reports provides the administrator ability to review GPO configuration from a browser.

Excel worksheet located under Report directory provides the deltas between previous GPO release to current GPO release. For detailed information of item changes review the Revision History document for accompanying STIG.

Windows 10 Defender Exploit Protection XML file (DISA_STIG_WDEP_v1R11.xml) is located under the DoD Windows 10 v1r11 directory. The Exploit Protection "Use a common set of exploit protections settings" setting within the DoD Windows 10 STIG Computer v1r11 GPO must be modified by system administrators from "\\YOUR_FOLDER_SHARE\DISA_STIG_WDEP_v1R11.xml" to a valid share within production environment. Each enterprise must establish a share to host exploit protection xml and copy the provided xml to enterprise share. The DISA_STIG_WDEP_v1R11.xml file has all required STIG settings configured. Each of the exploit protection settings are marked open in Windows 10 checklist. 

KNOWN ISSUES
------------
The Windows Server 2008 R2, Windows Server 2012 R2, and Windows Server 2016 member server GPO are configured to the most strictest setting (Local Account instead of Local account and member of Administrators group) for user right assignments values. The setting Deny access to this computer from the network must be relaxed to Local account and member of Administrators group on a system attempting to configured as member of cluster.


FILE STRUCTURE
--------------

ADMX Templates
|-Google
|	|-en-US
|	|      |-chrome.adml
|	|      |-google.adml
|	|      |-GoogleUpdate.adml
|	|
|	|-chrome.admx
|	|-google.admx
|	|-GoogleUpdate.admx
|
|-Microsoft
|	   |-en-US
|	   |      |-AdmPwd.adml
|	   |      |-MSS-legacy.adml
|	   |      |-SecGuide.adml
|	   |
|	   |-AdmPwd.admx
|	   |-MSS-legacy.admx
|	   |-SecGuide.admx
|
|-Office 2013
|	|-en-US
|	|      |-access15.adml                                                                    
|	|      |-excel15.adml                                                                     
|	|      |-inf15.adml                                                                       
|	|      |-lync15.adml                                                                      
|	|      |-office15.adml                                                                    
|	|      |-onent15.adml                                                                     
|	|      |-outlk15.adml                                                                     
|	|      |-ppt15.adml                                                                       
|	|      |-proj15.adml                                                                      
|	|      |-pub15.adml                                                                       
|	|      |-spd15.adml                                                                       
|	|      |-visio15.adml                                                                     
|	|      |-word15.adml 
|	|
|	|-access15.admx                                                                    
|       |-excel15.admx                                                                     
|       |-inf15.admx                                                                       
|       |-lync15.admx                                                                      
|       |-office15.admx                                                                    
|       |-onent15.admx                                                                     
|       |-outlk15.admx                                                                     
|       |-ppt15.admx                                                                       
|       |-proj15.admx                                                                      
|       |-pub15.admx                                                                       
|       |-spd15.admx                                                                       
|       |-visio15.admx                                                                     
|       |-word15.admx
|
|-Office 2016
|	|-en-US
|	|      |-access16.adml                                                                    
|	|      |-excel16.adml                                                                     
|	|      |-lync16.adml                                                                      
|	|      |-office16.adml                                                                    
|	|      |-onent16.adml                                                                     
|	|      |-outlk16.adml                                                                     
|	|      |-ppt16.adml                                                                       
|	|      |-proj16.adml                                                                      
|	|      |-pub16.adml                                                                       
|	|      |-visio16.adml                                                                     
|	|      |-word16.adml 
|	|
|	|-access16.admx                                                                    
|       |-excel16.admx                                                                     
|       |-lync16.admx                                                                      
|       |-office16.admx                                                                    
|       |-onent16.admx       -                                                              
|       |-outlk16.admx                                                                     
|       |-ppt16.admx                                                                       
|       |-proj16.admx                                                                      
|       |-pub16.admx                                                                       
|       |-visio16.admx                                                                     
|       |-word16.admx
|
|-OneDrive NextGen
|	|-en-US
|	|      |-OneDrive.adml
|	|-OneDrive.admx 
|                                                                  
|-DoD Google Chrome v1r11
|	|-Checklist
|	|	|-DoD Google Chrome v1r11.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Google Chrome v1r11.htm
|	|-WMI Filter
|	|	|-Google Chrome.mof
|                                                        
|-DoD Internet Explorer 11 v1r14 
|	|-Checklist
|	|	|-DoD Internet Explorer 11 v1r14.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Internet Explorer 11 STIG Computer v1r13.htm
|	|    |-DoD Internet Explorer 11 STIG User v1r13.htm
|	|-WMI Filter
|	|	|-Internet Explorer 11.mof
|                                                                       
|-DoD Office System 2013 and Components  
|	|-Checklist
|	|	|-DoD Access 2013 STIG v1r5.ckl
|	|	|-DoD Excel 2013 STIG v1r6.ckl
|	|	|-DoD Groove 2013 STIG v1r2.ckl
|	|	|-DoD InfoPath 2013 STIG v1r4.ckl
|	|	|-Lync 2013 STIG v1r3.ckl
|	|	|-DoD Office System 2013 v1r5.ckl
|	|	|-DoD OneNote 2013 STIG v1r2.ckl
|	|	|-DoD Outlook 2013 STIG v1r11.ckl
|	|	|-DoD PowerPoint 2013 STIG v1r5.ckl
|	|	|-DoD Project 2013 v1r3.ckl
|	|	|-DoD Publisher 2013 STIG v1r4.ckl
|	|	|-DoD SharePoint Designer 2013 STIG v1r2.ckl
|	|	|-DoD Visio 2013 STIG v1r3.ckl
|	|	|-DoD Word 2013 STIG v1r5.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|	|-DoD Access 2013 STIG v1r5.htm
|	|	|-DoD Excel 2013 STIG v1r6.htm
|	|	|-DoD Groove 2013 STIG v1r2.htm
|	|	|-DoD InfoPath 2013 STIG v1r4.htm
|	|	|-Lync 2013 STIG v1r3.htm
|	|	|-DoD Office System 2013 v1r5.htm
|	|	|-DoD OneNote 2013 STIG v1r2.htm
|	|	|-DoD Outlook 2013 STIG v1r11.htm
|	|	|-DoD PowerPoint 2013 STIG v1r5.htm
|	|	|-DoD Project 2013 v1r3.htm
|	|	|-DoD Publisher 2013 STIG v1r4.htm
|	|	|-DoD SharePoint Designer 2013 STIG v1r2.htm
|	|	|-DoD Visio 2013 STIG v1r3.htm
|	|	|-DoD Word 2013 STIG v1r5.htm
|	|-WMI Filter
|	|	|-Access 2013.mof
|	|	|-Excel 2013.mof
|	|	|-Groove (OneDrive) 2013.mof
|	|	|-InfoPath 2013.mof
|	|	|-Lync 2013.mof
|	|	|-Microsoft Office 2013.mof
|	|	|-OneNote 2013.mof
|	|	|-Outlook 2013.mof
|	|	|-PowerPoint 2013.mof
|	|	|-Project 2013.mof
|	|	|-Publisher 2013.mof
|	|	|-Visio 2013.mof
|	|	|-Word 2013.mof
|                                                               
|-DoD Office System 2016 and Components
|	|-Checklist
|	|	|-DoD Access 2016 STIG v1r1.ckl
|	|	|-DoD Excel 2016 STIG v1r2.ckl
|	|	|-DoD Office System 2016 STIG v1r1.ckl
|	|	|-DoD OneDrive for Business 2016 STIG v1r2.ckl
|	|	|-DoD OneNote 2016 STIG v1r2.ckl
|	|	|-DoD Outlook 2016 v1r2.ckl
|	|	|-DOD PowerPoint 2016 STIG v1r1.ckl
|	|	|-DoD Project 2016 STIG v1r1.ckl
|	|	|-DoD Publisher 2016 STIG v1r2.ckl
|	|	|-DoD Skype for Business 2016 STIG v1r1.ckl
|	|	|-DoD Visio 2016 STIG v1r1.ckl
|	|	|-DoD Word 2016 STIG v1r1.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|	|-DoD Access 2016 STIG v1r1.htm
|	|	|-DoD Excel 2016 STIG v1r2.htm
|	|	|-DoD Office System 2016 STIG v1r1.htm
|	|	|-DoD OneDrive for Business 2016 STIG v1r2.htm
|	|	|-DoD OneNote 2016 STIG v1r2.htm
|	|	|-DoD Outlook 2016 v1r2.htm
|	|	|-DOD PowerPoint 2016 STIG v1r1.htm
|	|	|-DoD Project 2016 STIG v1r1.htm
|	|	|-DoD Publisher 2016 STIG v1r2.htm
|	|	|-DoD Skype for Business 2016 STIG v1r1.htm
|	|	|-DoD Visio 2016 STIG v1r1.htm
|	|	|-DoD Word 2016 STIG v1r1.htm     
|	|-WMI Filter
|	|	|-Access 2016.mof
|	|	|-Excel 2016.mof
|	|	|-Office System 2016.mof
|	|	|-OneDrive for Business 2016.mof
|	|	|-OneNote 2016.mof
|	|	|-Outlook 2016.mof
|	|	|-PowerPoint 2016.mof
|	|	|-Project 2016.mof
|	|	|-Publisher 2016.mof
|	|	|-Skype for Business 2016.mof
|	|	|-Visio 2016.mof
|	|	|-Word 2016.mof
|                                                                 
|-DoD Windows 10 v1r12 
|	|-Checklist
|	|	|-DoD Windows 10 v1r12.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows 10 STIG Computer v1r12.htm
|	|    |-DoD Windows 10 STIG User v1r12.htm
|	|-Windows Defender Exploit Protection XML
|	|	|-DISA_STIG_WDEP_v1r11.xml
|	|-WMI Filter
|	|	|-Windows 10.mof
|                                                                                 
|-DoD Windows 7 v1r28 
|	|-Checklist
|	|	|-DoD Windows 7 v1r29.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows 7 STIG Computer v1r29.htm
|	|    |-DoD Windows 7 STIG User v1r29.htm
|	|-WMI Filter
|	|	|-Windows 7.mof
|                                                                                  
|-DoD Windows 8 and 8.1 v1r20 
|	|-Checklist
|	|	|-DoD Windows 8 and 8.1 v1r20.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows 8 and 8.1 STIG Computer v1r20.htm
|	|    |-DoD Windows 8 and 8.1 STIG User v1r20.htm
|	|-WMI Filter
|	|	|-Windows 8 and 8.1.mof
|                                                                                
|-DoD Windows Firewall v1r6 
|	|-Checklist
|	|	|-DoD Windows Firewall v1r6.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows Firewall v1r6.htm
|
|-DoD Windows Defender Antivirus STIG Computer v1r3 
|	|-Checklist
|	|	|-DoD Windows Defender Antivirus v1r3.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows Defender Antivirus STIG Computer v1r3.htm
|	|-WMI Filter
|	|	|-Windows Defender Antivirus.mof
|                                                                                                                       
|-DoD Windows Server 2008 R2 MS and DC v1r25
|	|-Checklist
|	|	|-DoD Windows Server 2008 R2 DC v1r25.ckl
|	|	|-DoD Windows Server 2008 R2 MS v1r25.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows Server 2008 R2 Domain Controller STIG v1r25.htm
|	|    |-DoD Windows Server 2008 R2 Domain Controller STIG User v1r25.htm
|	|    |-DOD Windows Server 2008 R2 Domain Controller.xlsx
|	|    |-DoD Windows Server 2008 R2 Member Server STIG Computer v1r25.htm
|	|    |-DoD Windows Server 2008 R2 Member Server STIG User v1r25.htm
|	|    |-DOD Windows Server 2008 R2 Domain Controller.xlsx
|	|-WMI Filter
|	|	|-Windows Server 2008 R2 Domain Controller.mof
|	|	|-Windows Server 2008 R2 Member Server.mof
|                                                            
|-DoD Windows Server 2012 R2 MS and DC v2r11 
|	|-Checklist
|	|	|-DoD Windows Server 2012 R2 DC v2r11.ckl
|	|	|-DoD Windows Server 2012 R2 MS v2r11.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows Server 2012 R2 Domain Controller STIG v2r11.htm
|	|    |-DoD Windows Server 2012 R2 Domain Controller STIG User v2r11.htm
|	|    |-DOD Windows Server 2012 R2 Domain Controller.xlsx
|	|    |-DoD Windows Server 2012 R2 Member Server STIG Computer v2r11.htm
|	|    |-DoD Windows Server 2012 R2 Member Server STIG User v2r11.htm
|	|    |-DOD Windows Server 2012 R2 Member Server.xlsx
|	|-WMI Filter
|	|	|-Windows Server 2012 R2 Domain Controller.mof
|	|	|-Windows Server 2012 R2 Member Server.mof
|                                                            
|-DoD Windows Server 2016 MS and DC v1r2 
|	|-Checklist
|	|	|-DoD Windows Server 2016 DC v1r3.ckl
|	|	|-DoD Windows Server 2016 MS v1r3.ckl
|	|-GPO
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-{GUID}
|	|    |-manifest.xml
|	|-Report
|	|    |-DoD Windows Server 2016 Domain Controller STIG v1r3.htm
|	|    |-DoD Windows Server 2016 Domain Controller STIG User v1r3.htm
|	|    |-DOD Windows Server 2016 Domain Controller.xlsx
|	|    |-DoD Windows Server 2016 Member Server STIG Computer v1r3.htm
|	|    |-DoD Windows Server 2016 Member Server STIG User v1r3.htm
|	|    |-DOD Windows Server 2016 Member Server.xlsx
|	|-WMI Filter
|	|	|-Windows Server 2016 Domain Controller.mof
|	|	|-Windows Server 2016 Member Server.mof
