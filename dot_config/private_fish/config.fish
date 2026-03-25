if status is-interactive
    # Commands to run in interactive sessions can go here
end

function ya
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

function ytdlp
    set music_dir "/home/nakul/Music/"
    set media_choice (echo Podcasts\nyoutube mp3 | fzf)
    set path "$music_dir$media_choice/"
    if [ "$media_choice" =  "Podcasts" ]
        set pod_name (ls $path | fzf)
        set path "$path$pod_name/"
    end

    echo "Downloading to: $path"
    echo $argv
    yt-dlp --extract-audio --audio-format mp3 -o $path"%(title)s.%(ext)s" --embed-thumbnail --metadata-from-title  "%(artist)s - %(title)s" $argv
end





set PATH $PATH ~/.config/emacs/bin

alias  cz "chezmoi"
alias  cze "chezmoi edit --apply"
alias ytdl  "yt-dlp --extract-audio --audio-format mp3 -o \"~/Music/Podcasts/%(title)s.%(ext)s\" --embed-thumbnail --metadata-from-title \"%(artist)s - %(title)s\""

direnv hook fish | source
