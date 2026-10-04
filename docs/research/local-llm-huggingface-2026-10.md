# Model LLM local phù hợp máy CPU 16GB (không dGPU) — Research từ Hugging Face, Oct 2026

> Máy tham chiếu: CachyOS Linux, i5-1155G7 (4C/8T, tới 4.5GHz), RAM 16GB (~11GB khả dụng), Intel Iris Xe (shared VRAM, suy luận chính bằng CPU qua llama.cpp/Ollama), disk trống 216GB.
> Nguyên tắc: **chỉ đề xuất model chạy thực tế được trên CPU 16GB** — ưu tiên 3B–8B ở Q4_K_M/Q5 (GGUF) hoặc FP16/BF16 nhỏ 1B–3B. 12B–14B Q4 là giới hạn trên (chậm). Không đề xuất 30B/70B FP16 làm model chính.

## Kết luận nhanh (Top 3 cho máy này)

| Nhu cầu | Model chốt | Lệnh Ollama / GGUF | Vì sao |
|---|---|---|---|
| **Code** (tốt nhất/tầm trung) | [Qwen/Qwen2.5-Coder-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct) | `ollama run qwen2.5-coder:7b` (~4.7GB) | Code-specialist, 7.61B params, context 131k tokens, Apache-2.0 ([model card](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct)) |
| **Chat đa năng** (cân bằng nhất) | [Qwen/Qwen3-8B](https://huggingface.co/Qwen/Qwen3-8B) | `ollama run qwen3:8b` (~5.2GB theo [Ollama library](https://ollama.com/library/qwen3)) | 8.2B, hybrid thinking/non-thinking, hỗ trợ 100+ ngôn ngữ, context 32k native / 131k với YaRN ([model card](https://huggingface.co/Qwen/Qwen3-8B)) |
| **Nhẹ nhất / nhanh nhất CPU** | [HuggingFaceTB/SmolLM3-3B](https://huggingface.co/HuggingFaceTB/SmolLM3-3B) | `ollama run smollm3` hoặc GGUF ~2GB | 3B fully-open (Apache-2.0), dual reasoning, context tới 128k với YaRN, train 11T tokens ([model card](https://huggingface.co/HuggingFaceTB/SmolLM3-3B), [blog](https://huggingface.co/blog/smollm3)) |

Chi tiết từng model ở mục 2, bảng so sánh ở mục 3.

> Bổ sung 04/10/2026: [gemma-4-E2B-it](https://huggingface.co/google/gemma-4-E2B-it) (Q4 2.84GB) và [gemma-4-E4B-it](https://huggingface.co/google/gemma-4-E4B-it) (Q4 4.59GB) đã VERIFIED vừa máy — cân nhắc thay vị trí "nhẹ nhất" (SmolLM3-3B) bằng E2B và vị trí "đa năng nhẹ" bằng E4B nếu cần đa ngữ 140+ / Apache-2.0 (chi tiết mục 2.12–2.13, 4, 4b).

---

## 1. Phương pháp và lưu ý về "model mới 3–6 tháng gần nhất"

- Mọi model dưới đây đều được **mở trực tiếp trang huggingface.co/<org>/<model> để verify tồn tại, params, license, context** tại thời điểm research (Oct 2026). Mỗi claim có link inline tới model card / blog / repo chính thức.
- Về các tên mới 2026 (Qwen3.6-27B/35B-A3B, Qwen3.8-27B, Gemma 4 family, Muse Glimmer/Spark): đã verify trực tiếp card gốc ngày 04/10/2026 — xem **bảng trạng thái ở mục 4**. Kết quả: toàn bộ Gemma 4 (E2B/E4B/12B/26B-A4B/31B/DiffusionGemma), Qwen3.6-27B, Qwen3.6-35B-A3B, Qwen3.8-27B, Muse Glimmer-30B đều **tồn tại card gốc**; nhưng chỉ **Gemma 4 E2B/E4B (+12B ở giới hạn trên) là vừa RAM 16GB** nên được bổ sung vào mục 2.12–2.14. Các bản 26B–36B là EXISTS-BUT-TOO-BIG. Muse Spark vẫn STILL-UNVERIFIED (không có repo HF công khai).
- Suy luận CPU dùng [llama.cpp](https://github.com/ggml-org/llama.cpp) (hỗ trợ quant 1.5–8bit, backend CPU/Vulkan/SYCL cho Intel iGPU) và [Ollama Qwen3 library](https://ollama.com/library/qwen3) (các tag `qwen3:8b` ~5.2GB, `qwen3:4b` ~2.5GB đã đo thực tế trên registry).

## 2. Danh sách model đề xuất (14 model, đã verify tồn tại)

### 2.1. Qwen3-8B — Alibaba/Qwen (Trung Quốc) — chat đa năng, agent
- Link: [Qwen/Qwen3-8B](https://huggingface.co/Qwen/Qwen3-8B) | Blog: [Qwen3 blog](https://qwenlm.github.io/blog/qwen3/) | Repo: [QwenLM/Qwen3](https://github.com/QwenLM/Qwen3)
- Release: 28/04/2025 (dòng Qwen3; bản 2507 update giữa 2025). Thuộc thế hệ mới nhất đã ổn định GGUF/Ollama.
- Params: **8.2B** (non-embedding 6.95B), 36 layers, GQA 32Q/8KV. Context **32,768 native, 131,072 với YaRN**. Hỗ trợ **100+ ngôn ngữ** (có tiếng Việt qua đa ngữ, ghi trong card).
- License: **Apache-2.0**.
- GGUF khuyên dùng: **Q4_K_M ~4.9–5.2GB** (đối chiếu [Ollama qwen3:8b 5.2GB](https://ollama.com/library/qwen3)). RAM chạy: ~7–8GB (model + context 4–8k + overhead). Disk: ~6GB.
- Tốc độ kỳ vọng i5-1155G7 CPU (llama.cpp, 8 threads): **~8–15 tok/s** ở Q4, prompt processing vài chục tok/s. Thinking mode chậm hơn ~30–50%.
- Use-case: chat đa năng, agent/tool-calling (khuyên dùng [Qwen-Agent](https://github.com/QwenLM/Qwen-Agent)), dịch đa ngữ. Tắt thinking (`enable_thinking=False`, Temperature 0.7/TopP 0.8) khi cần nhanh.

### 2.2. Qwen3-4B — Alibaba/Qwen (Trung Quốc) — đa năng nhẹ
- Link: [Qwen/Qwen3-4B](https://huggingface.co/Qwen/Qwen3-4B)
- Release: 28/04/2025 cùng họ Qwen3.
- Params: **4.0B** (non-embedding 3.6B). Context **32k native / 131k YaRN**. 100+ ngôn ngữ.
- License: **Apache-2.0**.
- GGUF: **Q4_K_M ~2.5GB** (khớp [Ollama qwen3:4b 2.5GB](https://ollama.com/library/qwen3)). RAM: ~4–5GB. Tốc độ CPU: **~15–25 tok/s**.
- Use-case: máy yếu hơn, agent nhẹ, fallback khi Qwen3-8B chậm.

### 2.3. Qwen2.5-Coder-7B-Instruct — Alibaba/Qwen (Trung Quốc) — code
- Link: [Qwen/Qwen2.5-Coder-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct) | Blog: [Qwen2.5-Coder family](https://qwenlm.github.io/blog/qwen2.5-coder-family/) | Paper: [arXiv 2409.12186](https://arxiv.org/abs/2409.12186)
- Release: 11/2024 (ổn định, GGUF/Ollama phổ biến nhất cho code local).
- Params: **7.61B** (non-embedding 6.53B). Context **131,072 tokens**. Code + math + general.
- License: **Apache-2.0**.
- GGUF: **Q4_K_M ~4.5–4.7GB**. RAM: ~6–7GB. Tốc độ CPU: **~10–18 tok/s**.
- Use-case: **code generation/reasoning/fixing, code agent**. Lựa chọn code tốt nhất trong trần 16GB RAM.

### 2.4. Ministral 3 8B Instruct — Mistral AI (Pháp/EU) — chat + vision, mới nhất đã verify
- Link: [mistralai/Ministral-3-8B-Instruct-2512](https://huggingface.co/mistralai/Ministral-3-8B-Instruct-2512) | Blog: [Mistral 3 announcement](https://mistral.ai/news/mistral-3) | Paper: [arXiv 2601.08584](https://arxiv.org/abs/2601.08584)
- Release: **12/2025** (hậu tố `2512` = Dec 2025) — mới nhất trong danh sách verify được, edge-optimized.
- Params: **8.4B LM + 0.4B vision encoder**. Context **256k**. Đa ngữ gồm EN/FR/ES/DE/IT/PT/NL/ZH/JA/KO/AR (không liệt kê VI). Hỗ trợ function-calling/JSON, system prompt.
- License: **Apache-2.0**.
- GGUF: bản gốc **FP8 (~9GB)**; cần bản community **Q4_K_M ~5GB** mới vừa RAM 16GB. Card ghi FP8 vừa 12GB VRAM, Q4 nhẹ hơn. RAM CPU: ~7–8GB ở Q4. Tốc độ: **~8–14 tok/s**.
- Lưu ý: họ Ministral 3 rất mới nên GGUF community ít hơn Qwen; nếu Ollama chưa có tag, dùng GGUF từ collection [Ministral 3 additional checkpoints](https://huggingface.co/collections/mistralai/ministral-3-additional-checkpoints). Vision qua llama.cpp còn hạn chế — dùng text-only trên CPU.

### 2.5. SmolLM3-3B — HuggingFace Smol Models (Pháp/EU, community-open) — nhẹ, fully-open
- Link: [HuggingFaceTB/SmolLM3-3B](https://huggingface.co/HuggingFaceTB/SmolLM3-3B) | Blog: [SmolLM3 announcement](https://huggingface.co/blog/smollm3) | Repo: [huggingface/smollm](https://github.com/huggingface/smollm)
- Release: **08/07/2025** (theo blog chính thức).
- Params: **3B**, decoder-only + GQA + NoPE, pretrain **11.2T tokens**, midtrain reasoning 140B, SFT+APO. Context **64k train, 128k với YaRN**. 6 ngôn ngữ chính thức: EN/FR/ES/DE/IT/PT (**không có tiếng Việt chính thức**).
- License: **Apache-2.0**, công bố full data mixture + config ([collection GGUF](https://huggingface.co/collections/HuggingFaceTB/smollm3-686d33c1fdffe8e635317e23)).
- GGUF: **Q4_K_M ~1.9–2.1GB**. RAM: ~3–4GB. Tốc độ CPU: **~20–35 tok/s** (nhanh nhất nhóm).
- Use-case: model nhẹ nhất cho tác vụ hàng ngày, agent nhỏ, tool-calling (xml_tools/python_tools), fine-tune thử nghiệm.

### 2.6. gemma-3-4b-it — Google (Mỹ) — chat đa năng + đa ngữ mạnh
- Link: [google/gemma-3-4b-it](https://huggingface.co/google/gemma-3-4b-it) | Model page: [Gemma](https://ai.google.dev/gemma/docs/core) | Tech report: [Gemma 3](https://goo.gle/Gemma3Report)
- Release: **12/03/2025** (Gemma 3; IT variant). Multimodal (text+image in, text out).
- Params: **4B** (train 4T tokens). Context **128k**. Hỗ trợ **140+ ngôn ngữ** (mạnh nhất về đa ngữ, bao gồm tiếng Việt theo tài liệu Gemma).
- License: **Gemma Terms of Use** (cần accept điều khoản trên HF, không phải Apache/MIT).
- GGUF: **Q4_K_M ~2.5–2.7GB**. RAM: ~4–5GB. Tốc độ CPU: **~15–25 tok/s** (text-only; vision nặng hơn).
- Use-case: chat đa ngữ (tiếng Việt tốt), SUM/QA. Lưu ý license hạn chế hơn Apache.

### 2.7. gemma-3-270m-it — Google (Mỹ) — siêu nhẹ
- Link: [google/gemma-3-270m-it](https://huggingface.co/google/gemma-3-270m-it)
- Release: **08/2025** (bản 270M công bố giữa 2025).
- Params: **0.27B**, text-only, context **32k**.
- License: **Gemma Terms**.
- GGUF: **Q8/Q4 ~0.2–0.35GB**. RAM <1GB. Tốc độ CPU: **>50 tok/s**.
- Use-case: classification, rewrite, on-device, test pipeline. Không kỳ vọng reasoning/code.

### 2.8. Phi-4-mini-instruct — Microsoft (Mỹ) — reasoning nhỏ, CPU-friendly
- Link: [microsoft/Phi-4-mini-instruct](https://huggingface.co/microsoft/Phi-4-mini-instruct) | Blog: [Phi-4-mini](https://aka.ms/phi4-feb2025) | Paper: [arXiv 2503.01743](https://huggingface.co/papers/2503.01743)
- Release: **02/2025**.
- Params: **3.8B** dense, vocab 200k (đa ngữ tốt), context **128k**. Train 5T tokens. Hỗ trợ function-calling.
- License: **MIT**.
- GGUF: **Q4_K_M ~2.2–2.4GB**. RAM: ~3.5–4.5GB. Tốc độ: **~18–30 tok/s**.
- Hỗ trợ ngôn ngữ: AR/ZH/CZ/DA/NL/EN/FI/FR/DE/HE/HU/IT/JA/KO/NO/PL/PT/RU/ES/SV/TH/TR/UK (**không liệt kê VI** trong card).
- Use-case: math/logic, RAG nhỏ, latency-bound.

### 2.9. Llama-3.2-3B-Instruct — Meta (Mỹ) — chat/edge ổn định
- Link: [meta-llama/Llama-3.2-3B-Instruct](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct)
- Release: **25/09/2024**. Params **3.21B**, context **128k**, 8 ngôn ngữ chính thức (EN/DE/FR/IT/PT/HI/ES/TH — **không có VI**).
- License: **Llama 3.2 Community** (cần accept + tuân thủ use policy, giới hạn 700M MAU).
- GGUF: **Q4_K_M ~1.9–2.0GB**. RAM ~3–4GB. Tốc độ **~20–35 tok/s**.
- Use-case: assistant gọn, rewrite/summarize, on-device. Có bản quant SpinQuant/QLoRA chính thức cho edge.

### 2.10. DeepSeek-R1-Distill-Qwen-7B — DeepSeek (Trung Quốc) — reasoning/code
- Link: [deepseek-ai/DeepSeek-R1-Distill-Qwen-7B](https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B) | Repo: [DeepSeek-R1](https://github.com/deepseek-ai/DeepSeek-R1) | Paper: [arXiv 2501.12948](https://arxiv.org/abs/2501.12948)
- Release: **01/2025**. Base Qwen2.5-Math-7B, distill từ R1. Params **~7B**.
- License: **MIT** (ghi chú: base Qwen Apache-2.0).
- GGUF: **Q4_K_M ~4.5GB**. RAM ~6–7GB. Tốc độ **~8–15 tok/s** (reasoning dài nên wall-clock lâu).
- Lưu ý dùng: temperature 0.5–0.7, không system prompt, ép `<think>` đầu output (theo usage recommendation trong card).

### 2.11. gpt-oss-20b — OpenAI (Mỹ) — agent/reasoning MoE, giới hạn trên
- Link: [openai/gpt-oss-20b](https://huggingface.co/openai/gpt-oss-20b) | Blog: [Introducing gpt-oss](https://openai.com/index/introducing-gpt-oss/) | Repo: [openai/gpt-oss](https://github.com/openai/gpt-oss)
- Release: **05/08/2025**. MoE **21B total / 3.6B active**, 24 layers, context **128k**, harmony format. MXFP4 native: **chạy trong 16GB** theo OpenAI.
- License: **Apache-2.0**.
- Chạy local: `ollama pull gpt-oss:20b` / `ollama run gpt-oss:20b` ([hướng dẫn trong card](https://huggingface.co/openai/gpt-oss-20b)). Dung lượng Ollama ~12–14GB. RAM yêu cầu ~14–16GB → **sát trần máy này, chỉ thử khi RAM trống >12GB, đóng app khác, context ngắn**.
- Tốc độ CPU thuần: **chậm (vài tok/s)** vì MoE + format harmony; phù hợp thử nghiệm agent/tool-calling hơn là daily driver. **Không đặt làm model chính.**

### 2.12. gemma-4-E2B-it — Google DeepMind (Mỹ) — siêu nhẹ mới, Apache-2.0 [MỚI VERIFIED 04/10/2026]
- Link: [google/gemma-4-E2B-it](https://huggingface.co/google/gemma-4-E2B-it) | Blog: [Gemma 4 launch](https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/) | Tech report: [arXiv 2607.02770](https://arxiv.org/abs/2607.02770) | Docs: [model card](https://ai.google.dev/gemma/docs/core/model_card_4)
- Release: **07/2026** (collection [Gemma 4](https://huggingface.co/collections/google/gemma-4)). Params: **2.3B effective (5.1B với embeddings, kiến trúc PLE)**, 35 layers. Context **128k**. Đa ngữ 140+ (kế thừa họ Gemma). Multimodal text/image/audio in → text out.
- License: **Apache-2.0** (khác Gemma 3 dùng Gemma ToU — điểm cộng lớn).
- GGUF đã mở trang xác minh: [ggml-org/gemma-4-E2B-it-GGUF](https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF) — **Q4_0 2.84GB**, Q8_0 4.97GB, BF16 9.31GB. Repo thay thế: [unsloth/gemma-4-E2B-it-GGUF](https://huggingface.co/models?search=gemma-4-E2B+GGUF), [google/gemma-4-E2B-it-qat-q4_0-gguf](https://huggingface.co/models?search=gemma-4-E2B+GGUF). RAM: ~4–5GB ở Q4. Tốc độ CPU kỳ vọng: **~25–40 tok/s** (text-only).
- Use-case: thay thế/phối hợp SmolLM3-3B cho tác vụ nhẹ hàng ngày, on-device, RAG nhỏ. Lưu ý: trên llama.cpp CPU chỉ dùng text-only (vision/audio cần transformers + GPU).

### 2.13. gemma-4-E4B-it — Google DeepMind (Mỹ) — chat đa năng nhẹ mới, Apache-2.0 [MỚI VERIFIED 04/10/2026]
- Link: [google/gemma-4-E4B-it](https://huggingface.co/google/gemma-4-E4B-it) | Blog: [Gemma 4 launch](https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/)
- Release: **07/2026**. Params: **4.5B effective (8B với embeddings)**, 42 layers. Context **128k**. Đa ngữ 140+.
- License: **Apache-2.0**.
- GGUF đã mở trang xác minh: [ggml-org/gemma-4-E4B-it-GGUF](https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF) — **Q4_0 4.59GB**, Q8_0 8.03GB, BF16 15.1GB. Repo thay thế: [unsloth/gemma-4-E4B-it-GGUF](https://huggingface.co/models?search=gemma-4-E4B-it-GGUF) (~615k lượt quan tâm), [google/gemma-4-E4B-it-qat-q4_0-gguf](https://huggingface.co/models?search=gemma-4-E4B-it-GGUF). RAM: ~6–7GB ở Q4. Tốc độ CPU kỳ vọng: **~12–20 tok/s** (text-only, `-c 4096`).
- Use-case: ứng viên thay Qwen3-4B/gemma-3-4b cho chat đa ngữ + tool-calling (Reddit ghi nhận chạy 20+ tools ổn — xem mục 4b). Benchmark gốc: MMLU-Pro 69.4%, LiveCodeBench v6 52.0% ([model card](https://huggingface.co/google/gemma-4-E4B-it)).

### 2.14. gemma-4-12B-it — Google DeepMind (Mỹ) — giới hạn trên mới, thử nghiệm [MỚI VERIFIED 04/10/2026]
- Link: [google/gemma-4-12B-it](https://huggingface.co/google/gemma-4-12B-it) | Kiến trúc **Unified encoder-free** (text/image/audio chiếu trực tiếp vào decoder), 11.95B params, context **256k**, Apache-2.0.
- GGUF đã xác minh tồn tại (qua trang search HF): [unsloth/gemma-4-12b-it-GGUF](https://huggingface.co/models?search=gemma-4-12B-it-GGUF) (1.52M), [google/gemma-4-12B-it-qat-q4_0-gguf](https://huggingface.co/models?search=gemma-4-12B-it-GGUF), [bartowski/gemma-4-12B-it-GGUF](https://huggingface.co/models?search=gemma-4-12B-it-GGUF). Dung lượng Q4 ~7GB (bản Q5_K_XL ~8.6GB theo [Reddit r/LocalLLaMA](https://www.reddit.com/r/LocalLLaMA/comments/1txdcj9/gemma_4_12b_is_my_new_main_squeeze) — community, secondary). RAM: ~9–11GB → **sát trần 11GB khả dụng, chỉ thử khi đóng app khác, `-c 4096`, text-only**.
- Benchmark gốc: MMLU-Pro 77.2%, LiveCodeBench v6 72.0%, GPQA 78.8% ([model card](https://huggingface.co/google/gemma-4-12B-it)). **Không đặt làm model chính.**

### Không đề xuất làm chính
- Mọi bản **30B/70B FP16**: vượt trần RAM/CPU, chỉ chạy được với offload phức tạp và tốc độ không dùng được. Chi tiết từng tên ở bảng mục 4 (Qwen3.6-27B/35B-A3B, Qwen3.8-27B, Gemma 4 26B-A4B/31B/DiffusionGemma, Muse Glimmer-30B đều đã verify tồn tại nhưng loại vì size).

## 3. Bảng so sánh tổng hợp

| # | Model (HF link) | Org / Nước | Release | Params | Context | License | GGUF khuyên dùng / dung lượng | RAM ước tính | Tốc độ CPU i5-1155G7* | Tiếng Việt? | Use-case |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | [Qwen3-8B](https://huggingface.co/Qwen/Qwen3-8B) | Alibaba/Qwen — CN | 04/2025 | 8.2B | 32k / 131k YaRN | Apache-2.0 | Q4_K_M ~5.2GB | 7–8GB | 8–15 t/s | Có (100+ lang) | Chat đa năng, agent |
| 2 | [Qwen3-4B](https://huggingface.co/Qwen/Qwen3-4B) | Alibaba/Qwen — CN | 04/2025 | 4B | 32k / 131k | Apache-2.0 | Q4_K_M ~2.5GB | 4–5GB | 15–25 t/s | Có (100+ lang) | Đa năng nhẹ |
| 3 | [Qwen2.5-Coder-7B](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct) | Alibaba/Qwen — CN | 11/2024 | 7.6B | 131k | Apache-2.0 | Q4_K_M ~4.7GB | 6–7GB | 10–18 t/s | Gián tiếp (đa ngữ Qwen) | **Code** |
| 4 | [Ministral-3-8B](https://huggingface.co/mistralai/Ministral-3-8B-Instruct-2512) | Mistral AI — FR | 12/2025 | 8.8B (+vision) | 256k | Apache-2.0 | Q4_K_M ~5GB (community) | 7–8GB | 8–14 t/s | Không liệt kê | Chat EU, function-call |
| 5 | [SmolLM3-3B](https://huggingface.co/HuggingFaceTB/SmolLM3-3B) | HuggingFaceTB — FR/EU | 07/2025 | 3B | 64k / 128k YaRN | Apache-2.0 | Q4_K_M ~2GB | 3–4GB | 20–35 t/s | Không chính thức | **Nhẹ nhất** |
| 6 | [gemma-3-4b-it](https://huggingface.co/google/gemma-3-4b-it) | Google — US | 03/2025 | 4B | 128k | Gemma ToU | Q4_K_M ~2.6GB | 4–5GB | 15–25 t/s | Có (140+ lang) | Chat đa ngữ |
| 7 | [gemma-3-270m-it](https://huggingface.co/google/gemma-3-270m-it) | Google — US | 08/2025 | 0.27B | 32k | Gemma ToU | Q4 ~0.3GB | <1GB | 50+ t/s | Có (kế thừa) | Siêu nhẹ |
| 8 | [Phi-4-mini](https://huggingface.co/microsoft/Phi-4-mini-instruct) | Microsoft — US | 02/2025 | 3.8B | 128k | MIT | Q4_K_M ~2.3GB | 3.5–4.5GB | 18–30 t/s | Không liệt kê | Math/RAG nhỏ |
| 9 | [Llama-3.2-3B](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct) | Meta — US | 09/2024 | 3.2B | 128k | Llama 3.2 | Q4_K_M ~2GB | 3–4GB | 20–35 t/s | Không (8 lang, k có VI) | Edge/chat gọn |
| 10 | [R1-Distill-7B](https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B) | DeepSeek — CN | 01/2025 | 7B | 32k+ | MIT | Q4_K_M ~4.5GB | 6–7GB | 8–15 t/s | Gián tiếp | Reasoning |
| 11 | [gpt-oss-20b](https://huggingface.co/openai/gpt-oss-20b) | OpenAI — US | 08/2025 | 21B/3.6B act | 128k | Apache-2.0 | MXFP4/Ollama ~12–14GB | 14–16GB | vài t/s (CPU) | EN chủ yếu | Agent thử nghiệm, giới hạn trên |
| 12 | [gemma-4-E2B-it](https://huggingface.co/google/gemma-4-E2B-it) | Google — US | 07/2026 | 2.3B eff (5.1B) | 128k | Apache-2.0 | [Q4_0 2.84GB](https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF) | 4–5GB | 25–40 t/s | Có (140+ lang) | **Nhẹ mới, on-device** |
| 13 | [gemma-4-E4B-it](https://huggingface.co/google/gemma-4-E4B-it) | Google — US | 07/2026 | 4.5B eff (8B) | 128k | Apache-2.0 | [Q4_0 4.59GB](https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF) | 6–7GB | 12–20 t/s | Có (140+ lang) | Chat nhẹ, tool-call |
| 14 | [gemma-4-12B-it](https://huggingface.co/google/gemma-4-12B-it) | Google — US | 07/2026 | 11.95B | 256k | Apache-2.0 | Q4 ~7GB / Q5 ~8.6GB (unsloth/bartowski) | 9–11GB | ~8–12 t/s | Có (140+ lang) | Giới hạn trên, thử nghiệm |
| — | [OLMo-2-7B](https://huggingface.co/allenai/OLMo-2-1124-7B-Instruct) (dự bị) | Ai2 — US | 11/2024 | 7B | 4k+ | Apache-2.0 | Q4_K_M ~4.5GB | 6GB | 10–16 t/s | EN chủ yếu | Nghiên cứu fully-open |

\* Tốc độ là ước tính llama.cpp CPU 8 threads, Q4, context 2–4k. Thực tế phụ thuộc prompt length, thinking on/off, và backend (thử `--vulkan`/SYCL cho iGPU nhưng đừng kỳ vọng tăng lớn).

## 4. Bảng trạng thái verify các tên "mới 2026" (verify trực tiếp 04/10/2026)

| Tên | Card gốc (đã mở) | Trạng thái | Q4 ước tính / RAM | Kết luận cho máy này |
|---|---|---|---|---|
| [Qwen/Qwen3.6-27B](https://huggingface.co/Qwen/Qwen3.6-27B) (04/2026, 27B dense, Apache-2.0, ctx 262k) | ✅ | **EXISTS-BUT-TOO-BIG** | Q4 ~16–17GB / ~18–20GB RAM | Loại (vượt 11GB khả dụng) |
| [Qwen/Qwen3.6-35B-A3B](https://huggingface.co/Qwen/Qwen3.6-35B-A3B) (04/2026, MoE 35B total / 3B active, Apache-2.0) | ✅ | **EXISTS-BUT-TOO-BIG** | Q4 ~20GB (toàn bộ 35B vẫn phải nạp) | Loại |
| [Qwen/Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B) (08/2026, 27B dense + vision, Apache-2.0, ctx 262k–1M) | ✅ | **EXISTS-BUT-TOO-BIG** | Q4 ~16–17GB (card liệt kê 1310 quant nhưng cùng size-class) | Loại |
| [google/gemma-4-E2B-it](https://huggingface.co/google/gemma-4-E2B-it) (07/2026, 2.3B eff, Apache-2.0, ctx 128k) | ✅ + [GGUF ggml-org Q4_0 2.84GB](https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF) | **VERIFIED** | 2.84GB / ~4–5GB RAM | ✅ Đề xuất (mục 2.12) |
| [google/gemma-4-E4B-it](https://huggingface.co/google/gemma-4-E4B-it) (07/2026, 4.5B eff, Apache-2.0, ctx 128k) | ✅ + [GGUF ggml-org Q4_0 4.59GB](https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF) | **VERIFIED** | 4.59GB / ~6–7GB RAM | ✅ Đề xuất (mục 2.13) |
| [google/gemma-4-12B-it](https://huggingface.co/google/gemma-4-12B-it) (07/2026, 11.95B Unified, Apache-2.0, ctx 256k) | ✅ + GGUF [unsloth](https://huggingface.co/models?search=gemma-4-12B-it-GGUF) / [google QAT](https://huggingface.co/models?search=gemma-4-12B-it-GGUF) / [bartowski](https://huggingface.co/models?search=gemma-4-12B-it-GGUF) | **VERIFIED (giới hạn trên)** | Q4 ~7GB / ~9–11GB RAM | ⚠️ Thử nghiệm (mục 2.14) |
| [google/gemma-4-26B-A4B-it](https://huggingface.co/google/gemma-4-26B-A4B-it) (07/2026, MoE 25.2B total / 3.8B active, Apache-2.0, ctx 256k) | ✅ | **EXISTS-BUT-TOO-BIG** | Q4 ~14–18GB (toàn bộ 25.2B phải nạp; bản 4-bit ~18GB theo [InfoWorld](https://www.infoworld.com/article/4156597/googles-gemma-4-shines-on-local-systems-both-big-and-small.html) — secondary) | Loại (dù active chỉ 3.8B) |
| [google/gemma-4-31B-it](https://huggingface.co/google/gemma-4-31B-it) (07/2026, 30.7B dense, Apache-2.0) | ✅ | **EXISTS-BUT-TOO-BIG** | Q4 ~18GB / 62GB ở BF16 | Loại |
| [google/diffusiongemma-26B-A4B-it](https://huggingface.co/google/diffusiongemma-26B-A4B-it) (diffusion LM, 25.2B, Apache-2.0) | ✅ | **EXISTS-BUT-TOO-BIG + sai kiến trúc** | 25.2B + sampler diffusion cần accelerator, không có GGUF llama.cpp chủ lưu | Loại |
| [meta-models/Muse-Glimmer-30B](https://huggingface.co/meta-models/Muse-Glimmer-30B) (Meta, 08/2026, ~29.6B, Apache-2.0; org `meta-models`, không phải `meta-llama`) | ✅ + GGUF ([unsloth](https://huggingface.co/models?search=muse+glimmer)/[meta-models](https://huggingface.co/models?search=muse+glimmer)/lmstudio-community) + [NVFP4](https://huggingface.co/models?search=muse+glimmer) | **EXISTS-BUT-TOO-BIG** | K-Quant-17GB nhắm phần cứng 24GB VRAM (theo card) | Loại |
| Muse Spark (Meta, teacher của Glimmer) | ❌ (search HF 0 repo công khai; chỉ được nhắc là frontier model trong [card Glimmer](https://huggingface.co/meta-models/Muse-Glimmer-30B) + [safety report](https://ai.meta.com/static-resource/muse-spark-safety-and-preparedness-report/)) | **STILL-UNVERIFIED** | — | Loại (không có repo để tải) |

Ghi chú: toàn bộ Gemma 4 dùng **Apache-2.0** ([giấy phép Gemma 4](https://ai.google.dev/gemma/docs/gemma_4_license)), thoáng hơn Gemma 3 (Gemma ToU). Tech report chung: [arXiv 2607.02770](https://arxiv.org/abs/2607.02770). Blog gốc: [Gemma 4 launch](https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/), [Qwen3.6-27B](https://qwen.ai/blog?id=qwen3.6-27b), [Qwen3.6-35B-A3B](https://qwen.ai/blog?id=qwen3.6-35b-a3b), [Qwen3.8](https://qwen.ai/blog?id=qwen3.8).

## 4b. Gợi ý từ Reddit (tín hiệu cộng đồng — secondary, đã verify ngược HF)

> Mọi model được nhắc dưới đây đều đã đối chiếu card HF primary ở mục 2/4 trước khi ghi nhận.

- **r/LocalLLaMA — "Gemma 4 12B is my new main squeeze"** ([thread](https://www.reddit.com/r/LocalLLaMA/comments/1txdcj9/gemma_4_12b_is_my_new_main_squeeze), ~21/09/2026): khen **Unsloth Gemma 4 12B Q5_K_XL (~8.6GB)** cho coding local — 50 tok/s, context 32k + Q8 KV cache, "plug-and-play" hơn Qwen (không phải sửa tool-call XML→JSON như Qwen3). Lý do: quality/code tốt ở size vừa. Đối chiếu: [google/gemma-4-12B-it](https://huggingface.co/google/gemma-4-12B-it) ✅ nhưng 8.6GB + KV sát trần máy 11GB → chỉ thử nghiệm (mục 2.14).
- **r/LocalLLM — "How capable is Gemma4:e4b?"** ([thread](https://www.reddit.com/r/LocalLLM/comments/1smp96t/how_capable_is_gemma4e4b), 16/04/2026): ý kiến trái chiều về **gemma4:e4b** — một user chạy 20+ tools "flawlessly", số khác chê từ chối việc ("incapable") trên máy yếu/i7-4790K. Lý do liên quan máy này: E4B total ~8B, Q4 ~4.6GB vừa RAM 16GB. Đối chiếu: [google/gemma-4-E4B-it](https://huggingface.co/google/gemma-4-E4B-it) + [GGUF 4.59GB](https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF) ✅ → đề xuất thử (mục 2.13), kỳ vọng thực tế ở mức tác vụ nhẹ.
- **r/LocalLLaMA — "Gemma 4 26B-A4B GGUF Benchmarks" bởi u/danielhanchen (Unsloth)** ([thread](https://www.reddit.com/r/LocalLLaMA/comments/1sqrl1l/gemma_4_26ba4b_gguf_benchmarks/), ~04/2026): so KL-divergence các quant GGUF để chọn bản tốt nhất ([unsloth/gemma-4-26B-A4B-it-GGUF](https://huggingface.co/models?search=gemma-4-E2B+GGUF)). Lý do ghi nhận: quy trình chọn quant chuẩn cho Gemma 4. Đối chiếu: [google/gemma-4-26B-A4B-it](https://huggingface.co/google/gemma-4-26B-A4B-it) ✅ nhưng 25.2B total → loại cho máy này.
- **r/LocalLLaMA — "Best models for CPU without GPU?"** ([thread](https://www.reddit.com/r/LocalLLaMA/comments/18yz3ba/best_models_for_cpu_without_gpu), 2024, kinh điển): lời khuyên CPU-only — cần ≥16GB RAM để chạy 7B cùng app khác (7B chiếm 6–8GB, tránh swap). Khớp thực tế máy này (11GB khả dụng → trần Q4 ~7–8GB). Củng cố lựa chọn E2B/E4B/Phi-4-mini/SmolLM3.
- **r/LocalLLaMA — "Gemma 4 - MLX doesn't seem better than GGUF"** ([thread](https://www.reddit.com/r/LocalLLaMA/comments/1spn7zh/gemma_4_mlx_doesnt_seem_better_than_gguf), 19/04/2026): đo GGUF ≈ MLX (~52 tok/s) → không cần stack Apple/MLX, GGUF + llama.cpp là đường đúng cho máy CPU/iGPU Intel này.

## 5. Khuyến nghị cài đặt trên máy này (ante + llama.cpp, không dùng Ollama)

> Đã verify trên máy này (04/10/2026): engine tại `~/.ante/llama.cpp/current/llama` (build 11200, `cpu`), config `~/.ante/offline-config.json` (`threads: 8`, `gpu_layers: 0`, `host 127.0.0.1:8080`). Ante headless dùng cờ `--offline-model <PATH>` (xem `ante --help`).

### 5.1. Cách đúng: dùng `/offline-mode` trong TUI (khuyên dùng)

Theo [Offline Mode](https://docs.antigma.ai/local/offline#setting-up): mở `ante` → `/offline-mode` → mục **Verified models** ([list](https://docs.antigma.ai/local/verified-models)) → Ante tự tải từ Hugging Face, hiện progress bar + ước tính RAM trước. Vừa máy này: `Gemma 4 E4B-it Q4_K_M 4.7GB`, `Qwen3.5 9B 5.7GB`. Mấy con 14–22GB trong list (Qwen3.6 27B, Gemma 26B-A4B...) bỏ qua.
Ante tự quét GGUF ở `~/.ante/models`, `~/.cache/llama.cpp`, `~/.cache/huggingface/hub`, `~/.llama/models` ([Model discovery](https://docs.antigma.ai/local/offline#model-discovery)) — file tải tay bằng `llama download` vẫn hiện trong mục **Local models**, không cần `mkdir`/`symlink`. Ante mặc định cap context 32K, tăng bằng `ANTE_OFFLINE_CONTEXT` ([env](https://docs.antigma.ai/local/offline#environment-variables)).

### 5.2. Tải tay bằng llama (khi cần repo ngoài list)

```bash
# Các repo dưới đã mở trang verify 04/10/2026; luôn ghi rõ :quant
~/.ante/llama.cpp/current/llama download -hf ggml-org/Qwen3-8B-GGUF:Q4_K_M
~/.ante/llama.cpp/current/llama download -hf ggml-org/gemma-4-E4B-it-GGUF:Q4_0     # 4.59GB
~/.ante/llama.cpp/current/llama download -hf ggml-org/gemma-4-E2B-it-GGUF:Q4_0     # 2.84GB
# Kiểm tra cache thực tế (llama KHÔNG có lệnh delete — muốn xóa thì rm -rf thư mục repo):
~/.ante/llama.cpp/current/llama serve --cache-list
ls ~/.cache/huggingface/hub/ | grep -i gemma
# rm -rf ~/.cache/huggingface/hub/models--ggml-org--<ten-repo>
```

### 5.3. Add your own — đưa model ngoài list vào selector (verify từ doc gốc 04/10/2026)

Theo [Verified Models — Add your own](https://docs.antigma.ai/local/verified-models#add-your-own): Ante merge file `~/.ante/verified_models.json` lên trên built-in list lúc khởi động. `filename` trùng built-in thì override, `filename` mới thì append. File này chưa tồn tại trên máy này — tự tạo theo schema:

```json
{
  "models": [
    {
      "name": "Gemma 4 E2B-it",
      "repo": "ggml-org/gemma-4-E2B-it-GGUF",
      "filename": "<ten-file-gguf-chinh-xac-trong-repo>",
      "context_window": 32768,
      "file_size_mb": 2900,
      "kv_cache_bytes_per_token": 131072,
      "support_vision": false
    }
  ]
}
```

| Field | Nghĩa (theo doc gốc) |
|---|---|
| `name` | Tên hiển thị trong selector |
| `repo` | Repo Hugging Face chứa file |
| `filename` | Tên file GGUF trong repo (đồng thời là merge key) — copy chính xác từ trang repo |
| `context_window` | Context tối đa (token) — để 32768 cho máy này, đừng để 128k/256k |
| `file_size_mb` | Dung lượng tải, dùng để ước tính RAM |
| `kv_cache_bytes_per_token` | KV cache tăng mỗi token, dùng để ước tính RAM |
| `support_vision` | Có nhận ảnh không (optional) |

Xong mở `ante` → `/offline-mode` là thấy model tự thêm trong list.

### 5.4. Chạy

```bash
ante -p "giải thích đoạn code này" --offline-model ~/.cache/huggingface/hub/models--ggml-org--gemma-4-E4B-it-GGUF/snapshots/*/*.gguf
# hoặc trực tiếp llama (dùng -c nhỏ để vừa RAM — xem giải thích YaRN ở mục 3):
~/.ante/llama.cpp/current/llama cli -hf ggml-org/gemma-4-E4B-it-GGUF -c 4096 -n 512 --temp 1.0
~/.ante/llama.cpp/current/llama serve -hf ggml-org/gemma-4-E2B-it-GGUF -c 4096 --port 8080
```

Cú pháp `-hf`, `-c/--ctx-size` verify từ `llama download --help` và `llama serve --help` trên máy này; mẫu chung theo [llama.cpp quickstart](https://github.com/ggml-org/llama.cpp).
Lưu ý: đừng `-c 131072` theo quảng cáo YaRN — tràn RAM 16GB ngay, chỉ dùng `-c 4096/8192` hàng ngày.

<details>
<summary>Ollama (tham khảo, không dùng trên máy này)</summary>

```bash
ollama run qwen3:8b
ollama run qwen2.5-coder:7b
ollama run smollm3
```

</details>

## Sources (toàn bộ URL primary đã dùng + community secondary)

> Quy ước: URL không gắn nhãn = primary (model card / blog / announcement gốc). URL gắn `(community, secondary)` = tín hiệu cộng đồng, mọi model được nhắc đã verify ngược card HF.

- https://huggingface.co/Qwen/Qwen3-8B
- https://huggingface.co/Qwen/Qwen3-4B
- https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct
- https://huggingface.co/mistralai/Ministral-3-8B-Instruct-2512
- https://huggingface.co/HuggingFaceTB/SmolLM3-3B
- https://huggingface.co/google/gemma-3-4b-it
- https://huggingface.co/google/gemma-3-270m-it
- https://huggingface.co/microsoft/Phi-4-mini-instruct
- https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct
- https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B
- https://huggingface.co/openai/gpt-oss-20b
- https://huggingface.co/allenai/OLMo-2-1124-7B-Instruct
- https://huggingface.co/blog/smollm3
- https://huggingface.co/collections/HuggingFaceTB/smollm3-686d33c1fdffe8e635317e23
- https://huggingface.co/collections/mistralai/ministral-3-additional-checkpoints
- https://qwenlm.github.io/blog/qwen3/
- https://qwenlm.github.io/blog/qwen2.5-coder-family/
- https://github.com/QwenLM/Qwen3
- https://github.com/QwenLM/Qwen-Agent
- https://ai.google.dev/gemma/docs/core
- https://goo.gle/Gemma3Report
- https://aka.ms/phi4-feb2025
- https://huggingface.co/papers/2503.01743
- https://github.com/meta-llama/llama-models
- https://github.com/deepseek-ai/DeepSeek-R1
- https://arxiv.org/abs/2501.12948
- https://openai.com/index/introducing-gpt-oss/
- https://github.com/openai/gpt-oss
- https://arxiv.org/abs/2508.10925
- https://mistral.ai/news/mistral-3
- https://arxiv.org/abs/2601.08584
- https://github.com/huggingface/smollm
- https://github.com/ggml-org/llama.cpp
- https://ollama.com/library/qwen3
- https://benchlm.ai/model-updates/releases/april-2026 (tham khảo phụ, không dùng làm nguồn duy nhất)
- https://benchlm.ai/model-updates/providers/alibaba (tham khảo phụ)
- https://huggingface.co/Qwen/Qwen3.6-27B (verify 04/10/2026 — EXISTS-BUT-TOO-BIG)
- https://huggingface.co/Qwen/Qwen3.6-35B-A3B (verify 04/10/2026 — EXISTS-BUT-TOO-BIG)
- https://huggingface.co/Qwen/Qwen3.8-27B (verify 04/10/2026 — EXISTS-BUT-TOO-BIG)
- https://qwen.ai/blog?id=qwen3.6-27b
- https://qwen.ai/blog?id=qwen3.6-35b-a3b
- https://qwen.ai/blog?id=qwen3.8
- https://huggingface.co/google/gemma-4-E2B-it (verify 04/10/2026 — VERIFIED)
- https://huggingface.co/google/gemma-4-E4B-it (verify 04/10/2026 — VERIFIED)
- https://huggingface.co/google/gemma-4-12B-it (verify 04/10/2026 — VERIFIED, giới hạn trên)
- https://huggingface.co/google/gemma-4-26B-A4B-it (verify 04/10/2026 — EXISTS-BUT-TOO-BIG)
- https://huggingface.co/google/gemma-4-31B-it (verify 04/10/2026 — EXISTS-BUT-TOO-BIG)
- https://huggingface.co/google/diffusiongemma-26B-A4B-it (verify 04/10/2026 — EXISTS-BUT-TOO-BIG)
- https://huggingface.co/collections/google/gemma-4
- https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF (verify 04/10/2026 — Q4_0 2.84GB)
- https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF (verify 04/10/2026 — Q4_0 4.59GB)
- https://huggingface.co/meta-models/Muse-Glimmer-30B (verify 04/10/2026 — EXISTS-BUT-TOO-BIG)
- https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/
- https://ai.google.dev/gemma/docs/core/model_card_4
- https://ai.google.dev/gemma/docs/gemma_4_license
- https://arxiv.org/abs/2607.02770
- https://ai.meta.com/static-resource/muse-spark-safety-and-preparedness-report/
- https://www.reddit.com/r/LocalLLaMA/comments/1txdcj9/gemma_4_12b_is_my_new_main_squeeze (community, secondary)
- https://www.reddit.com/r/LocalLLM/comments/1smp96t/how_capable_is_gemma4e4b (community, secondary)
- https://www.reddit.com/r/LocalLLaMA/comments/1sqrl1l/gemma_4_26ba4b_gguf_benchmarks/ (community, secondary)
- https://www.reddit.com/r/LocalLLaMA/comments/18yz3ba/best_models_for_cpu_without_gpu (community, secondary)
- https://www.reddit.com/r/LocalLLaMA/comments/1spn7zh/gemma_4_mlx_doesnt_seem_better_than_gguf (community, secondary)
- https://www.infoworld.com/article/4156597/googles-gemma-4-shines-on-local-systems-both-big-and-small.html (community/press, secondary)
- https://ollama.com/library/gemma4 (tham khảo tag quy ước, không dùng Ollama trên máy này)
- https://docs.antigma.ai/local/verified-models (doc gốc Ante: curated list + Add your own schema verified_models.json)
- https://docs.antigma.ai/local/offline (doc gốc Ante: /offline-mode, model discovery, ANTE_OFFLINE_CONTEXT)
