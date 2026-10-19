## What
<!-- O que muda, em linguagem simples -->

## Why
<!-- Qual problema resolve ou qual etapa avança -->

## How I tested
<!-- Comando rodado e resultado, ex.: dbt build --select staging → PASS=21 WARN=0 ERROR=0 -->

## Checklist
- [ ] `dbt build` passes locally for the changed models
- [ ] New models have description and grain in YAML
- [ ] Primary keys have `unique` and `not_null` tests
- [ ] README/DEVLOG updated if behavior changed

Closes #