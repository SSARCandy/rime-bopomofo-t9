-- rime.lua
-- T9 智慧排序 v11 (雙模優化版)

function t9_sort_filter(input, env)
    local context = env.engine.context
    local input_str = context.input
    local input_len = #input_str
    
    -- 只有當最後一個字元是聲調時，才啟用「強制完美匹配」提拔模式
    local is_anchored = input_str:match("[qwxy]$") ~= nil

    local cands = {}
    local count = 0
    for cand in input:iter() do
        cands[#cands + 1] = cand
        count = count + 1
        if count >= 200 then break end
    end

    local buckets = {}
    local max_cov = 0
    
    for i = 1, #cands do
        local cand = cands[i]
        local c_end = cand._end or cand["end"] or 0
        local cov = c_end - cand.start
        
        if cov > max_cov then max_cov = cov end
        
        if not buckets[cov] then 
            buckets[cov] = { perfect = {}, others = {} } 
        end
        
        -- 核心改動：只有在定錨模式下，才把完美匹配拆出來放前面
        if is_anchored and c_end == input_len then
            table.insert(buckets[cov].perfect, cand)
        else
            table.insert(buckets[cov].others, cand)
        end
    end

    -- 輸出邏輯
    for i = max_cov, 1, -1 do
        local b = buckets[i]
        if b then
            -- 定錨模式下，perfect 優先輸出
            -- 非定錨模式下，perfect 陣列為空，others 保留 RIME 原始頻率順序輸出
            for _, cand in ipairs(b.perfect) do yield(cand) end
            for _, cand in ipairs(b.others) do yield(cand) end
        end
    end

    -- 保底
    for cand in input:iter() do
        yield(cand)
    end
end
