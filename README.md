# Simulácia Dentálneho Strediska

## Popis
Tento repozitár obsahuje MATLAB kód pre simuláciu operácií v dentálnom stredisku. Cieľom simulácie je optimalizovať pracovný čas lekárov a minimalizovať čakacie doby pacientov, pričom sa zároveň dbá na prevenciu vyhorenia zamestnancov.

## Funkcionalita
Simulácia zohľadňuje rôzne aspekty, ako sú príchody pacientov, urgentné prípady, a dĺžka ošetrení, s variabilitou v čase príchodu a pravdepodobnosti komplikácií.

### Kľúčové Triedy
- `Doctor`: Reprezentuje lekára, spravuje jeho dostupnosť a ošetrovanie pacientov.
- `Patient`: Obsahuje informácie o pacientoch, vrátane času príchodu, začiatku ošetrenia, a či ide o urgentný prípad.
- `Clinic`: Koordinuje udalosti a spracovanie pacientov v rámci kliniky.
- `StatisticsManager`: Zaznamenáva a vyhodnocuje štatistiky z operácií kliniky.
- `SimulationManager`: Riadi spustenie viacerých experimentov pre rôzne scenáre.

### Scenáre
Simulácia testuje rôzne scenáre rozvrhovania pacientov, aby identifikovala optimálne nastavenia pre minimálne čakacie doby a efektívne využitie zdrojov.

## Inštalácia
1. Naklonujte repozitár:

'''
git clone https://github.com/your-username/clinic-simulation.git
'''

2. Otvorte súbory projektu v prostredí MATLAB.

## Použitie
Spustenie aplikácie/simulačného kódu

Nastavenia pre rôzne scenáre a parametre simulácie možno upraviť v aplikácii/skripte podľa potreby.

## Výsledky
Simulácia poskytuje podrobné výstupy vrátane čakacích časov pacientov, vyťaženosti lekárov a iných kľúčových metrík operácií. Výsledky pomáhajú identifikovať optimálne strategie pre plánovanie a správu pacientov.

