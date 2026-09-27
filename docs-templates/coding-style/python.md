# CODING_STYLE.md — {{NAZWA}}

> Konwencje kodu Python. Trzymaj się ich konsekwentnie — kod niezgodny
> z tym dokumentem poprawiaj przy okazji, zamiast dodawać niespójność.

<!-- kickoff: wzorzec dla Pythona. Dopasuj do wybranego frameworka i odpowiedzi użytkownika. -->

## 1. Narzędzia
- Python 3.12+, zarządzanie zależnościami: `uv` (albo zgodnie z ARCHITECTURE.md).
- Formatowanie i lint: `ruff format` + `ruff check`. Typy: `mypy --strict` (albo `pyright`).

## 2. Typowanie
- Adnotacje typów dla wszystkich funkcji publicznych i atrybutów klas.
- Dane z zewnątrz walidowane na granicy (np. pydantic) — dalej już typ.

## 3. Nazewnictwo
| Element | Konwencja | Przykład |
|---|---|---|
| Moduły, funkcje, zmienne | snake_case | `fetch_user` |
| Klasy | PascalCase | `UserProfile` |
| Stałe | UPPER_SNAKE_CASE | `MAX_RETRIES` |
| Prywatne | prefiks `_` | `_parse_row` |

## 4. Struktura
- Układ `src/<pakiet>/`, jeden moduł = jedna odpowiedzialność.
- Logika biznesowa oddzielona od frameworka i I/O.

## 5. Błędy
- Własne wyjątki domenowe; nigdy gołe `except:`; nie połykaj wyjątków.
- Logowanie przez `logging`, nie `print`.

## 6. Komentarze
- Komentarz wyjaśnia **dlaczego**, nie **co**. Docstring dla publicznego API.

## 7. Testy
- pytest, katalog `tests/` odwzorowujący `src/`.
- Test na każde wymaganie z PRD, które da się sprawdzić automatycznie.
- Wszystko: `bash executor/verify.sh`.
