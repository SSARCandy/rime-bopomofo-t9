-- rime.lua
-- T9 智慧排序 v16 (分段選詞 + 首音節提拔版)
--
-- 解決的問題：輸入長串注音時，整句猜測常常不對，而正確的「第一個詞」
-- （覆蓋較短）在舊版排序（覆蓋度嚴格降冪）下被大量錯誤的長匹配壓到
-- 列表深處，導致難以分段選字。
--
-- 排序策略：
--   1. 完整覆蓋（吃滿所有輸入）的候選最優先：整句猜測、完整詞。
--      選了就直接上屏，猜對時維持一鍵完成。
--   2. 首音節提拔（v16 新增）：若第一個音節有聲調錨定，該音節的最佳
--      單字固定排在整句猜測正後方。規則可預期：「猜錯時，第 2 個候選
--      永遠是第一個音節的最佳字」——『有、的、就、也』這類單字虛詞
--      不會再被中長度的錯誤配對（如 有+比較 併猜）壓到後面。
--   3. 其餘部分覆蓋的候選依覆蓋長度分桶，「輪流」輸出：
--      第一輪輸出每種長度的最佳候選（由長到短），第二輪輸出次佳……
--      如此每種「首段斷詞長度」的好選擇都會出現在候選列前端，
--      選字後 RIME 會自動對剩餘輸入繼續出候選，即可一段一段選完。
--   4. 「孤兒聲調」候選：若候選字結束的位置後面緊跟著聲調鍵
--      (q/w/x/y)，表示這種斷法會讓聲調鍵變成下一段的開頭——
--      沒有任何音節以聲調開頭，屬於無效斷詞，壓到最後。
--      （有打聲調時，這會大幅過濾掉斷錯位置的雜訊。）

-- 配置常數
local MAX_CANDS = 80        -- 參與排序的候選數上限（其餘按原始順序附在後面）
local TONE_SET = "[qwxy]"   -- 聲調鍵字元（q:ˉ w:ˊ x:ˇ y:ˋ）

function t9_sort_filter(input, env)
    local context = env.engine.context
    local input_str = context.input
    if not input_str or input_str == "" then
        for cand in input:iter() do yield(cand) end
        return
    end
    local input_len = #input_str

    -- 1. 收集前 MAX_CANDS 個候選
    local cands = {}
    local count = 0
    for cand in input:iter() do
        count = count + 1
        cands[count] = cand
        if count >= MAX_CANDS then break end
    end
    if count == 0 then return end

    -- 2. 分類：完整覆蓋 / 依覆蓋長度分桶 / 孤兒聲調
    local full = {}      -- 吃滿所有輸入的候選
    local buckets = {}   -- cov -> 候選列表（保持 RIME 原始順序）
    local orphans = {}   -- 斷在聲調鍵前的無效斷詞
    local max_cov = 0
    local seg_start = cands[1].start or 0   -- 同段候選共享起點

    for i = 1, count do
        local cand = cands[i]
        -- 兼容性處理：有些版本的 librime-lua 使用 _end，有些使用 end
        local c_end = cand._end or cand["end"] or 0
        local c_start = cand.start or 0
        local cov = c_end - c_start

        if c_end >= input_len then
            table.insert(full, cand)
        elseif input_str:sub(c_end + 1, c_end + 1):match(TONE_SET) then
            table.insert(orphans, cand)
        else
            if cov > max_cov then max_cov = cov end
            local b = buckets[cov]
            if not b then
                b = {}
                buckets[cov] = b
            end
            table.insert(b, cand)
        end
    end

    -- 3. 首音節提拔：第一個聲調鍵標記了第一個完整音節的結束位置，
    --    該音節的最佳單字固定排在完整覆蓋候選之後（單字虛詞救星）
    local promoted = nil
    for i = seg_start + 1, input_len do
        if input_str:sub(i, i):match(TONE_SET) then
            local b = buckets[i - seg_start]
            if b and b[1] then
                promoted = table.remove(b, 1)
            end
            break
        end
    end

    -- 4. 完整覆蓋優先輸出，其次是首音節最佳候選
    for _, cand in ipairs(full) do
        yield(cand)
    end
    if promoted then
        yield(promoted)
    end

    -- 5. 各覆蓋長度輪流輸出（每輪由長到短各出一個）
    local round = 1
    local emitted = true
    while emitted do
        emitted = false
        for cov = max_cov, 0, -1 do
            local b = buckets[cov]
            local cand = b and b[round]
            if cand then
                yield(cand)
                emitted = true
            end
        end
        round = round + 1
    end

    -- 6. 無效斷詞墊底
    for _, cand in ipairs(orphans) do
        yield(cand)
    end

    -- 7. 保底：輸出剩餘未處理的候選字
    for cand in input:iter() do
        yield(cand)
    end
end
