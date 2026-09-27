---
name: plan-milestone
description: Rozbija aktualny milestone z ROADMAP.md na 5–10 małych, sekwencyjnych zadań dla wykonawcy, z mierzalnym kryterium ukończenia każdego, zapisuje kolejkę w ORCHESTRATION_STATE.md i czeka na akceptację użytkownika. Używaj, gdy użytkownik wpisze /plan-milestone, po zakończeniu /kickoff albo gdy aktualny milestone nie ma jeszcze kolejki zadań.
---

# /plan-milestone — rozbicie milestone'a na zadania

Milestone to za duży kęs na jedno zlecenie. Rozbijasz go na zadania,
z których każde = jedno zlecenie, jedna weryfikacja, jeden commit.

## Procedura

1. Przeczytaj `AGENTS.md`, `ROADMAP.md`, `ORCHESTRATION_STATE.md`
   (Lekcje!), `ARCHITECTURE.md` i dokumenty systemów, których dotyczy
   milestone.
2. Wybierz milestone: oznaczony 🔵 W TRAKCIE, a jeśli brak — pierwszy ⬜.
   Oznacz go w ROADMAP.md jako 🔵.
3. Jeśli poprzedni milestone zostawił dług (zablokowane zadania, lekcje,
   rzeczy „czego nie zrobiono”) — zaproponuj, żeby poszedł na początek.
4. Rozpisz **5–10 zadań**, każde w formacie:
   ```
   N. **<M>-<n>: <tytuł>** — <co konkretnie powstaje/zmienia się>.
      *Kryterium:* <mierzalne: test, komenda, metryka, zachowanie w przeglądarce/terminalu>
   ```
   Zasady:
   - każde zadanie w granicach **jednego systemu/modułu**;
   - kolejność sekwencyjna — późniejsze mogą korzystać z wcześniejszych;
   - kryterium sprawdzalne przez Ciebie (nie „działa dobrze”);
   - zadania z UI mają w kryterium sprawdzenie w działającej aplikacji (zrzut ekranu);
   - nowy system → pierwsze zadanie tworzy też `MODULES/MODULE_<nazwa>.md`;
   - ostatnie zadanie = weryfikacja kryterium całego milestone'a z ROADMAP.
5. Nad listą dopisz „Założenia wspólne” (gałąź `m<N>-<krótka-nazwa>`,
   zasady obowiązujące wszystkie zadania, decyzje techniczne podjęte przy
   rozbiciu, rzeczy niemierzalne automatycznie → krótki playtest
   użytkownika na koniec).
6. Zapisz w `## Kolejka zadań` w `ORCHESTRATION_STATE.md`.
7. Pokaż listę użytkownikowi i zapytaj (AskUserQuestion):
   „Akceptujesz kolejkę <M>?” → „Akceptuję — startuj” / „Chcę zmian”.
   **Nie zlecasz niczego przed akceptacją.**
8. Po akceptacji: `git switch -c m<N>-<krótka-nazwa>`, commit stanu
   (`chore: kolejka zadań <M>`), zaproponuj `/orchestrate`.
