# ARCHITECTURE.md — {{NAZWA}}

<!-- kickoff: jak zbudowany jest projekt. Agent czyta to przed każdym zadaniem technicznym.
Każda decyzja z uzasadnieniem w 1 zdaniu; szczegóły → DECISIONS.md. -->

## 1. Stack techniczny

<!-- kickoff: język + wersja, framework, baza, kluczowe biblioteki, środowisko uruchomieniowe. -->

## 2. Struktura projektu

<!-- kickoff: drzewo katalogów (blok kodu) z komentarzem przy każdym katalogu.
Domyślna rekomendacja: podział według modułów/funkcji, nie według typu pliku. -->

## 3. Model danych

<!-- kickoff: encje, relacje, kluczowe pola, gdzie przechowywane, migracje. -->

## 4. Interfejsy

<!-- kickoff: API (endpointy/komendy CLI/publiczne funkcje), format wejścia/wyjścia, wersjonowanie. -->

## 5. Obsługa błędów i logowanie

<!-- kickoff: jak zgłaszamy błędy użytkownikowi, co logujemy, czego NIE logujemy (dane osobowe, sekrety). -->

## 6. Bezpieczeństwo, konfiguracja i sekrety

<!-- kickoff: uwierzytelnianie/autoryzacja, walidacja wejścia, skąd konfiguracja (.env, zmienne), gdzie sekrety. -->

## 7. Zależności

<!-- kickoff: lista zależności z uzasadnieniem; zasada: nowa zależność tylko za zgodą użytkownika. -->

## 8. Jak uruchomić / testować

<!-- kickoff: DOKŁADNE komendy: instalacja, uruchomienie, jeden test, wszystkie testy (= bash executor/verify.sh),
konwencja testów (gdzie leżą, jak nazwane). -->

## 9. Weryfikacja UI

<!-- kickoff: tylko jeśli jest UI — jak uruchomić aplikację i zrobić zrzut ekranu (claude-in-chrome / Playwright),
jakie rozdzielczości sprawdzać. Bez UI: usuń tę sekcję. -->

## 10. Deploy

<!-- kickoff: gdzie i jak wdrażamy, środowiska, CI. -->

## 11. Otwarte pytania / do ustalenia później
