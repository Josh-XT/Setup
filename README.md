Speichere das Skript:
Öffne ein Terminal und erstelle eine neue Datei mit dem gewünschten Namen, zum Beispiel setup_kubuntu.sh:

    bash
                    nano setup_kubuntu.sh


Füge den oben stehenden Skriptinhalt in die Datei ein und speichere sie mit Ctrl + O, dann beende den Editor mit Ctrl + X.

Mache das Skript ausführbar:

bash

    chmod +x setup_kubuntu.sh

Führe das Skript aus:

Da das Skript administrative Rechte benötigt, führe es mit sudo aus:

bash

    sudo ./setup_kubuntu.sh

Starte das System neu:

Nach erfolgreicher Ausführung des Skripts wird empfohlen, das System neu zu starten, um alle Änderungen wirksam zu machen:

bash

    sudo reboot

Hinweise
    Docker Rootless:
    Das Skript installiert Docker im Rootless-Modus. Stelle sicher, dass du die Docker-Rootless-Dokumentation hier für weitere Konfigurationen und Optimierungen konsultierst, insbesondere wenn du Docker ausschließlich über SSH nutzen möchtest.
    CPU Turbo und pstate Einstellungen:
    Einige CPU-Turbo-Einstellungen und pstate-Konfigurationen sind hardware- und BIOS-spezifisch. Stelle sicher, dass Turbo-Boost im BIOS aktiviert ist. Das Skript setzt die CPU-Frequenz auf den Performance-Modus, aber weitere Optimierungen können je nach Bedarf erforderlich sein.
    Firewall-Einstellungen:
    Das Skript erlaubt die Ports 5000, 3000, 8080 und 8000 und blockiert Port 22. Passe die Firewall-Einstellungen nach Bedarf an, falls du andere Ports verwenden möchtest oder zusätzliche Sicherheitsmaßnahmen benötigst.    Fehlerbehandlung:
    Das Skript wurde so konzipiert, dass es bei Fehlern weiterläuft und diese in der Log-Datei protokolliert. Überprüfe bei Problemen die Log-Datei unter /var/log/kubuntu_setup.log für detaillierte Fehlermeldungen.
    Systemkompatibilität:
    Dieses Skript ist für Kubuntu 24.04 und die angegebenen Hardware-Spezifikationen optimiert. Passe das Skript gegebenenfalls an andere Versionen oder Hardware-Konfigurationen an.
    Nach dem Neustart:
    Stelle sicher, dass alle Dienste korrekt gestartet wurden und überprüfe die Funktionalität der installierten Anwendungen und Tools.

Bei weiteren Fragen oder Problemen stehe ich gerne zur Verfügung!
