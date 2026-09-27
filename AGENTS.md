# AGENTS.md

> Ten plik czytasz jako pierwszy, zanim zaczniesz jakąkolwiek pracę nad projektem.
> Zawiera podstawowe zasady, strukturę i to, czego NIE wolno robić bez pytania.
>
> <!-- Wypełnia /kickoff. Dopóki są tu placeholdery {{…}}, projekt nie ma dokumentów. -->

## Czym jest ten projekt

**Nazwa robocza:** {{NAZWA}}

**Typ projektu:** {{TYP_PROJEKTU}}

**Stack:** {{STACK}} (szczegóły — patrz `ARCHITECTURE.md`)

**Użytkownicy:** {{UZYTKOWNICY}}

**Problem, który rozwiązuje:** {{PROBLEM}}

Pełny opis wymagań: patrz `PRD.md`.

## Kolejność czytania dokumentacji

1. `AGENTS.md` (ten plik) — zawsze najpierw
2. `PRD.md` — co budujemy, dla kogo i po co
3. `ARCHITECTURE.md` — jak jest zbudowany projekt, jak uruchomić i testować
4. `ROADMAP.md` — na jakim etapie jesteśmy, co jest w zakresie obecnego milestone'a
5. `MODULES/*.md` — szczegóły konkretnego modułu, nad którym akurat pracujesz
6. `CODING_STYLE.md` — konwencje kodu
7. `UI_STYLE.md` — konwencje interfejsu (jeśli projekt ma UI)
8. `GLOSSARY.md` — ustalone nazwy domenowe, żeby nie wymyślać nowych terminów
9. `DECISIONS.md` — historia decyzji, zanim zaproponujesz coś, co mogło już
   zostać rozważone i odrzucone

## Zasady pracy dla agenta

- **Nie zmieniaj zakresu.** Pracuj tylko nad zleconym zadaniem z bieżącego
  milestone'a w `ROADMAP.md`.
- **Nie zmieniaj architektury, struktury katalogów ani publicznych interfejsów**
  (API, schemat bazy, format plików) bez wyraźnej zgody — jeśli coś wymaga
  refaktoru, opisz to w raporcie.
- **Nie dodawaj nowych zależności** bez wyraźnego polecenia.
- **Trzymaj się `CODING_STYLE.md`** — nie wprowadzaj własnych konwencji.
- **Nazwy domenowe** (encje, pola, komunikaty) — zgodnie z `GLOSSARY.md`.
- **Sekrety** (klucze, hasła, tokeny) nigdy w kodzie ani w repo — tylko
  zmienne środowiskowe / menedżer sekretów, zgodnie z `ARCHITECTURE.md`.
- **Istotne decyzje projektowe** zapisuj w `DECISIONS.md` (co, dlaczego,
  jakie były alternatywy).
- Jeśli czegoś brakuje w dokumentacji, żeby wykonać zadanie — napisz to
  w raporcie, zamiast zgadywać.

## Jak uruchomić / testować

Patrz `ARCHITECTURE.md` → „Jak uruchomić / testować”. Pełna weryfikacja
projektu: `bash executor/verify.sh` (exit 0 = zielono).

## Status dokumentacji

| Dokument | Status |
|---|---|
| AGENTS.md | ⬜ |
| PRD.md | ⬜ |
| ARCHITECTURE.md | ⬜ |
| ROADMAP.md | ⬜ |
| CODING_STYLE.md | ⬜ |
| UI_STYLE.md (opcjonalny) | ⬜ |
| GLOSSARY.md | ⬜ |
| DECISIONS.md | ⬜ |
| MODULES/README.md | ⬜ |

*(Aktualizuj tę tabelę przy tworzeniu/kończeniu każdego dokumentu.)*
