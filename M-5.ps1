# M-5 computer, yes that M-5
 
$global:destructStage = 0
Add-Type -AssemblyName System.Speech
Add-Type -AssemblyName presentationCore
Add-Type -AssemblyName System.Windows.Forms   # for SendKeys once, not in loop
Add-Type -AssemblyName System.Web            # for URL encoding (Outlook)

# Initialize speech recognizer
$recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine
$recognizer.LoadGrammar((New-Object System.Speech.Recognition.DictationGrammar))
$recognizer.SetInputToDefaultAudioDevice()

# Initialize media player
$player = New-Object System.Windows.Media.MediaPlayer

Write-Host "Computer online. Awaiting command..."
Write-Host "You may speak OR type commands."
Write-Host "M-5 tie in."

while ($true) {

    # --- 1. LISTEN FOR VOICE (with confidence filter) ---
    $voice = $null
    try {
        $result = $recognizer.Recognize()
        if ($result -ne $null -and $result.Confidence -ge 0.65) {
            $voice = $result.Text.ToLower()
        }
    } catch {}

    # --- 2. CHECK FOR TYPED INPUT (always allowed) ---
    $typed = $null
    if ([Console]::KeyAvailable) {
        $typed = Read-Host "Enter command"
        $typed = $typed.ToLower()
    }

    # --- 3. PRIORITY: typed > voice ---
    if ($typed) {
        $command = $typed
    }
    elseif ($voice) {
        $command = $voice
    }
    else {
        continue
    }

    # Ignore tiny noise words from voice input
    if (-not $typed -and $command.Length -lt 3) {
        continue
    }

    # --- 4. COMMAND MATCHING ---
    switch -Regex ($command) {

        # --- UNIVERSAL MESSAGE SENDER ---
        ".*(send|compose|message).*(whatsapp|outlook).*" {

            # Determine app
            if ($command -match "whatsapp") {
                $app = "whatsapp"
            } elseif ($command -match "outlook") {
                $app = "outlook"
            } else {
                Write-Host "Specify WhatsApp or Outlook."
                continue
            }

            # Ask for details
            $recipient = Read-Host "Who is the message for"
            if ([string]::IsNullOrWhiteSpace($recipient)) {
                Write-Host "Recipient cannot be empty."
                continue
            }

            $subject = Read-Host "What is the subject"
            if ([string]::IsNullOrWhiteSpace($subject)) {
                $subject = "(no subject)"
            }

            $msg = Read-Host "What is the message"
            if ([string]::IsNullOrWhiteSpace($msg)) {
                $msg = "(no message)"
            }

            # --- WHATSAPP DESKTOP ---
            if ($app -eq "whatsapp") {

                Write-Host "Opening WhatsApp Desktop..."
                Start-Process "shell:AppsFolder\5319275A.WhatsAppDesktop_cv1g1gvanyjgm!App"
                Start-Sleep -Seconds 2

                # Copy message to clipboard
                Set-Clipboard -Value $msg

                # WhatsApp UI automation
                [System.Windows.Forms.SendKeys]::SendWait("^f")
                Start-Sleep -Milliseconds 500

                # Escape special characters for SendKeys
                $safeRecipient = $recipient.Replace("{","{{").Replace("}","}}").Replace("+","{+}").Replace("^","{^}")

                [System.Windows.Forms.SendKeys]::SendWait($safeRecipient)
                Start-Sleep -Seconds 1

                [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
                Start-Sleep -Seconds 1

                [System.Windows.Forms.SendKeys]::SendWait("^v")
                Start-Sleep -Milliseconds 300

                [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

                Write-Host "WhatsApp message sent to $recipient."
                # $player.Open("Insert mp3 filepath here")
                $player.Play()
                continue
            }

            # --- NEW OUTLOOK (mailto method) ---
if ($app -eq "outlook") {

    Write-Host "Opening New Outlook compose window..."

    # URL encode fields
    $encodedTo      = [System.Web.HttpUtility]::UrlEncode($recipient).Replace("+","%20")
    $encodedSubject = [System.Web.HttpUtility]::UrlEncode($subject).Replace("+","%20")
    $encodedBody    = [System.Web.HttpUtility]::UrlEncode($msg).Replace("+","%20")

    # mailto:recipient?subject=SUBJECT&body=BODY
    $mailto = "mailto:$encodedTo`?subject=$encodedSubject&body=$encodedBody"

    Start-Process $mailto

    Write-Host "Outlook compose window opened for $recipient."
    # $player.Open$player.Open("Insert mp3 filepath here")
    $player.Play()
    continue
}

        }

        # --- DESTRUCT SEQUENCE 1 ---
        ".*destruct sequence 1.*1-1a.*" {
            if ($global:destructStage -eq 0) {
                Write-Host "Destruct Sequence 1 accepted."
                $global:destructStage = 1
            } else {
                Write-Host "Destruct Sequence 1 rejected. Incorrect order."
            }
        }

        # --- DESTRUCT SEQUENCE 2 ---
        ".*destruct sequence 2.*1-1a-2b.*" {
            if ($global:destructStage -eq 1) {
                Write-Host "Destruct Sequence 2 accepted."
                $global:destructStage = 2
            } else {
                Write-Host "Destruct Sequence 2 rejected. Incorrect order."
            }
        }

        # --- DESTRUCT SEQUENCE 3 ---
        ".*destruct sequence 3.*1-b-2-b-3.*" {
            if ($global:destructStage -eq 2) {
                Write-Host "Destruct Sequence 3 accepted."
                $global:destructStage = 3
            } else {
                Write-Host "Destruct Sequence 3 rejected. Incorrect order."
            }
        }

        # --- FINAL AUTHORIZATION ---
        ".*(code zero zero zero destruct zero|code 000 destruct 0|destruct zero).*" {
            if ($global:destructStage -eq 3) {
                Write-Host "Final Destruct Authorization accepted."
                 # $player.Open("Insert mp3 filepath here")
                $player.Play()
                $global:destructStage = 0
            } else {
                Write-Host "Final Destruct Authorization rejected. Sequence incomplete."
            }
        }

        ".*(code 123 continuity abort destruct order).*" {
            Write-Host "Abort command detected."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(warp (one|1|won)|warp (two|2|to|too)|warp (three|3)|warp (four|4|for)|warp (five|5)|warp (six|6)|warp (seven|7)|warp (eight|8|ate)|warp (nine|9)|warp speed|engage warp).*" {
            Write-Host "Warp command detected."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(shields up|raise shields).*" {
            Write-Host "Shields up."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(fire phasers).*" {
            Write-Host "Phasers firing."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(fire torpedos |fire photon torpedos).*" {
            Write-Host "Torpedos away."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(red alert|computer, red alert|initiate red alert|battle stations|condition red).*" {
            Write-Host "Red alert command detected."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(take us out|ahead full|ahead one quarter impulse|take her out).*" {
            Write-Host "Departure command detected."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(intro|space, the final frontier|computer, play intro).*" {
            Write-Host "Intro command detected."
            # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        ".*(alt intro|space, the final conquest|computer, play alt intro).*" {
            Write-Host "Alt Intro command detected."
             # $player.Open("Insert mp3 filepath here")
            $player.Play()
        }

        # --- NEWS HEADLINES -> OLLAMA SUMMARY ---
        ".*(news headlines|top headlines|summarize headlines|summarize news|headlines).*" {

            Write-Host "Accessing current news headlines from NYPost U.S. News and Yeshiva World News..."
            # $player.Open("Insert mp3 filepath here")
            $player.Play()

            $headlines = @()

            # --- NYPOST (U.S. NEWS RSS - NO OPINION, NO JS) ---
            try {
                $nyRss = Invoke-WebRequest -Uri "https://nypost.com/news/us-news/feed/" -UseBasicParsing
                $nyXml = [xml]$nyRss.Content

                $nyTitles = $nyXml.rss.channel.item.title |
                    Where-Object { $_ -and $_.Trim().Length -gt 20 } |
                    Select-Object -First 5

                if ($nyTitles.Count -gt 0) {
                    $headlines += "New York Post - U.S. News:"
                    $headlines += $nyTitles
                }
                else {
                    $headlines += "New York Post: (no headlines found)"
                }
            }
            catch {
                $headlines += "New York Post: (unable to retrieve)"
            }

            # --- YESHIVA WORLD NEWS (RSS FEED - RELIABLE) ---
            try {
                $ywnRss = Invoke-WebRequest -Uri "https://www.theyeshivaworld.com/feed" -UseBasicParsing
                $ywnXml = [xml]$ywnRss.Content

                $ywnTitles = $ywnXml.rss.channel.item.title |
                    Where-Object { $_ -and $_.Trim().Length -gt 20 } |
                    Select-Object -First 5

                if ($ywnTitles.Count -gt 0) {
                    $headlines += ""
                    $headlines += "Yeshiva World News:"
                    $headlines += $ywnTitles
                }
                else {
                    $headlines += ""
                    $headlines += "Yeshiva World News: (no headlines found)"
                }
            }
            catch {
                $headlines += ""
                $headlines += "Yeshiva World News: (unable to retrieve)"
            }

            if ($headlines.Count -eq 0) {
                Write-Host "No headlines could be retrieved."
                continue
            }

            $headlineText = ($headlines -join "`n")

             # $player.Open("Insert mp3 filepath here")
            $player.Play()

            Write-Host "`n--- M-5 News ---"
            Write-Host $headlineText
            Write-Host "----------------------`n"
            continue
        }

        default {

            # --- AI WAKE WORD ---
            if ($command -match '^library computer:\s*(.+)$') {
                $prompt = $matches[1]

                if ([string]::IsNullOrWhiteSpace($prompt)) {
                    Write-Host "No query provided for Library Computer."
                    continue
                }

                Write-Host "Accessing Library Computer Data..."
                 # $player.Open("Insert mp3 filepath here")
                $player.Play()

                $response = ollama run phi3:mini "$prompt"

                 # $player.Open("Insert mp3 filepath here")
                $player.Play()

                Write-Host "`n--- Library Computer Response ---"
                Write-Host $response
                Write-Host "---------------------------------`n"
                continue
            }

            Write-Host "Command not recognized."
            continue
        }
    }
}
