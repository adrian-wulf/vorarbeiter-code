# CODING_STYLE.md — {{NAZWA}}

> Konwencje kodu TypeScript. Trzymaj się ich konsekwentnie — kod niezgodny
> z tym dokumentem poprawiaj przy okazji, zamiast dodawać niespójność.

<!-- kickoff: wzorzec dla TypeScript. Dopasuj do wybranego frameworka i odpowiedzi użytkownika. -->

## 1. Narzędzia
- Formatowanie: Prettier (domyślna konfiguracja projektu). Lint: ESLint z `typescript-eslint`.
- `tsconfig`: `"strict": true`, `"noUncheckedIndexedAccess": true`.

## 2. Typowanie
- Zakaz `any` — w wyjątkowych przypadkach `unknown` + zawężanie typu.
- Typy zwracane jawne dla funkcji eksportowanych.
- Dane z zewnątrz (API, formularze, env) walidowane na granicy (np. zod) — dalej już typ.

## 3. Nazewnictwo
| Element | Konwencja | Przykład |
|---|---|---|
| Zmienne, funkcje | camelCase | `fetchUser` |
| Typy, interfejsy, klasy, komponenty | PascalCase | `UserProfile` |
| Stałe modułowe | UPPER_SNAKE_CASE | `MAX_RETRIES` |
| Pliki | kebab-case (komponenty React: PascalCase) | `user-service.ts` |

## 4. Struktura
- Jeden moduł = jedna odpowiedzialność; eksporty nazwane, bez `default export`.
- Logika biznesowa oddzielona od frameworka (czyste funkcje, łatwe do testów).

## 5. Błędy
- Nie połykaj wyjątków; błąd albo obsłużony (z komunikatem dla użytkownika), albo przekazany dalej.
- `async`/`await` zamiast łańcuchów `.then`; każda obietnica obsłużona.

## 6. Komentarze
- Komentarz wyjaśnia **dlaczego**, nie **co**. JSDoc dla publicznego API.

## 7. Testy
- Vitest (lub Jest — zgodnie z ARCHITECTURE.md), pliki `*.test.ts` obok testowanego kodu.
- Test na każde wymaganie z PRD, które da się sprawdzić automatycznie.
- Wszystko: `bash executor/verify.sh`.
