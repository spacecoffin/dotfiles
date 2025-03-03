hs.loadSpoon('EmmyLua')

----------------------------------------------------------------------------------------
-- sqlfluff
----------------------------------------------------------------------------------------

SQLFluffPath = "$HOME/.local/bin/sqlfluff"

function MakeArgument(argument, value)
    if value then
        return "--" .. argument .. " " .. value
    end
    return ""
end

function MakeFmtFnString(dialect, templater, excludeRules)
    dialect = MakeArgument("dialect", dialect)
    templater = MakeArgument("templater", templater)
    excludeRules = MakeArgument("exclude-rules", excludeRules)

    local formatString = [[
        function fmt {
            cd $HOME
            local SQLFILE=$HOME/.hssqlfluff.sql
            pbpaste > $SQLFILE
            %s fix %s %s %s --ignore=templating $SQLFILE > $HOME/.hssqlfluff.log
            cat $SQLFILE | pbcopy
        }
        fmt
    ]]
    return string.format(formatString, SQLFluffPath, dialect, templater, excludeRules)
end

function MakePressedFn(dialect, templater, excludeRules)
    return function()
        hs.eventtap.keyStroke({ "cmd" }, "c")
        local output, status = hs.execute(MakeFmtFnString(dialect, templater, excludeRules), false)

        if status then
            hs.eventtap.keyStroke({ "cmd" }, "v")
        else
            hs.alert('Attempting to format with sqlfluff failed.')
        end
    end
end

-- "Default" Fix ; currently Databricks Dialect
hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "F", nil, MakePressedFn("databricks", "jinja"))

-- Fix MySQL
hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "M", nil, MakePressedFn("mysql", "placeholder")) -- "python"))

-- Fix SparkSQL
hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "S", nil, MakePressedFn("sparksql", "python"))

-- Lint Databricks
hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "D", nil, function()
    hs.eventtap.keyStroke({ "cmd" }, "c")
    local output, status = hs.execute([[
        function lnt {
            cd $HOME
            local SQLFILE=$HOME/.hssqlfluff.sql
            pbpaste > $SQLFILE
            $HOME/.local/bin/sqlfluff lint --dialect databricks --templater jinja $SQLFILE > $HOME/.hssqlfluff.log
        }
        lnt
    ]], false)
end)

-- Lint SparkSQL
hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "N", nil, function()
    hs.eventtap.keyStroke({ "cmd" }, "c")
    local output, status = hs.execute([[
        function lnt {
            cd $HOME
            local SQLFILE=$HOME/.hssqlfluff.sql
            pbpaste > $SQLFILE
            $HOME/.local/bin/sqlfluff lint --dialect sparksql --templater jinja $SQLFILE > $HOME/.hssqlfluff.log
        }
        lnt
    ]], false)
end)


----------------------------------------------------------------------------------------
-- Sublime Text style Upper Case text
----------------------------------------------------------------------------------------

-- https://github.com/babarrett/hammerspoon/blob/master/editSelection.lua

-- getTextSelection()
--  Gets currently selected text using Cmd+C
--  Saves and restores the current pasteboard
--  Imperfect, perhaps. May not work well on large selections.
--  Taken from: https://github.com/Hammerspoon/hammerspoon/issues/634
function GetTextSelection() -- returns text or nil while leaving pasteboard undisturbed.
    local oldText = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({ "cmd" }, "c")
    hs.timer.usleep(25000)
    local text = hs.pasteboard.getContents() -- if nothing is selected this is unchanged
    hs.pasteboard.setContents(oldText)
    if text ~= oldText then
        return text
    else
        return ""
    end
end

function ToUppercase()
    local sel = GetTextSelection()
    if sel then hs.eventtap.keyStrokes(string.upper(sel)) end
end

hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "U", nil, ToUppercase)
--hs.uielement:selectedText().upper()

function ToLowercase()
    local sel = GetTextSelection()
    if sel then hs.eventtap.keyStrokes(string.lower(sel)) end
end

hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "L", nil, ToLowercase)


----------------------------------------------------------------------------------------
-- BigQuery labels
----------------------------------------------------------------------------------------

function GetDefaultBQLabels()
    hs.eventtap.keyStrokes([[SET @@query_label = "product:feature-store";
SET @@query_label = "team:ds";
SET @@query_label = "executor:rrosenberg";

]])
end

hs.hotkey.bind({ "alt", "cmd", "ctrl", "shift" }, "Q", nil, GetDefaultBQLabels)


----------------------------------------------------------------------------------------
-- Spoons
----------------------------------------------------------------------------------------

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
