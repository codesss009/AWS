-- filepath: /Users/sarath/cloud-projects/scripts/timesheet-automate.applescript
-- timesheet-automate.applescript
-- Opens TrackerRMS, logs in, navigates to "This Week" timesheet,
-- ensures the timesheet tab is active, takes a screenshot of the current screen, and emails.

-- CONFIG
set loginUrl to "https://evoportalus.tracker-rms.com/Resource/Login?db=MillenniumConsulting&page=logon"
set userEmail to "sarath.chennu243@gmail.com"
set userPassword to "Juru5187"
-- set recipientEmail to "sarath.chennu243@gmail.com" -- dry run, send to yourself
set recipientEmail to "globalhighsolutions@gmail.com"
set screenshotPath to (POSIX path of (path to desktop)) & "timesheet.png"

-- DATE STRINGS (calculate Sunday of the previous week)
set today to (current date)
set dayOfWeek to (weekday of today as integer) - 1 -- Adjust so Sunday = 0, Monday = 1, ..., Saturday = 6
set daysSinceLastSunday to dayOfWeek -- Days to subtract to get to the most recent Sunday
set lastSunday to today - (daysSinceLastSunday * days) -- Subtract to get the most recent Sunday
set previousSunday to lastSunday - (7 * days) -- Subtract 7 more days to get the Sunday of the previous week
set {year:y, month:m, day:d} to previousSunday
set monthName to (m as string) -- e.g., "October"

set subjectText to "Timesheets for the week ending " & d & " " & monthName & " " & y
set bodyText to "Hello Swetha,\n\nPFA the approved timesheets for the week ending " & d & " " & monthName & " " & y & ".\n\nBest,\nSarath"

-- STEP 1. Open Chrome and login
tell application "Google Chrome"
    activate
    set newTab to make new tab at end of window 1 with properties {URL:loginUrl}
    delay 5
    
    tell newTab
        execute javascript "document.getElementById('Email').value='" & userEmail & "';"
        execute javascript "document.getElementById('Password').value='" & userPassword & "';"
        execute javascript "document.querySelector('form').submit();"
    end tell
end tell

-- STEP 2. Wait for dashboard to load
delay 10

-- STEP 3. Navigate to "This Week" timesheet
tell application "Google Chrome"
    tell active tab of window 1
        execute javascript "document.querySelector(\"a[href*='Timesheet/Details'][href*='lwk=false']\").click();"
    end tell
end tell

-- STEP 4. Wait for timesheet page to load
delay 10

-- STEP 5. Ensure the timesheet tab is active and Chrome is in focus
tell application "Google Chrome"
    activate -- Bring Chrome to the foreground
    set index of window 1 to 1 -- Ensure the first Chrome window is active
end tell

-- STEP 6. Take a screenshot of the current screen
do shell script "screencapture -x " & quoted form of screenshotPath

-- STEP 7. Email the screenshot
tell application "Mail"
    set newMessage to make new outgoing message with properties {subject:subjectText, content:bodyText, visible:true}
    tell newMessage
        make new to recipient at end of to recipients with properties {address:recipientEmail}
        make new attachment with properties {file name:screenshotPath} at after the last paragraph
        set sender to "sarath.chennu243@gmail.com"
    end tell
    send newMessage
end tell