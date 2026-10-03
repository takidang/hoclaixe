# Ví dụ schema dữ liệu (điều chỉnh trong /data-plan)

```json
{
  "id": "Q0001",
  "content": "…",
  "image": "assets/images/q0001.png",
  "options": ["…", "…", "…"],
  "correctIndex": 1,
  "topic": "khai-niem-quy-tac",
  "isCritical": true,
  "licenseClasses": ["A1", "B"],
  "explanation": "…",
  "legalRefs": [{"doc": "<số hiệu văn bản>", "article": "Điều x", "clause": "Khoản y"}],
  "sourceVersion": "<phiên bản bộ đề>"
}
```

Chunk luật cho RAG:
```json
{
  "id": "LAW-<văn bản>-D<điều>-K<khoản>",
  "docTitle": "…", "docNumber": "…", "effectiveDate": "YYYY-MM-DD",
  "chapter": "…", "article": "Điều x", "clause": "Khoản y",
  "text": "…"
}
```

Danh mục biển báo (`data/sign-catalog/signs.json`):
```json
{
  "code": "<mã biển theo quy chuẩn>",
  "name": "…",
  "group": "cam | nguy_hiem | hieu_lenh | chi_dan | phu",
  "meaning": "…",
  "image": "assets/signs/<code>.png",
  "relatedQuestionIds": ["Q0123"],
  "source": {"doc": "<số hiệu quy chuẩn>", "effectiveDate": "YYYY-MM-DD"}
}
```
