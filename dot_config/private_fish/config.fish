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

set PATH $PATH ~/.config/emacs/bin

alias  cz "chezmoi"
alias  cze "chezmoi edit --apply"
alias ytdl  "yt-dlp --extract-audio --audio-format mp3 -o \"~/Music/Podcasts/%(title)s.%(ext)s\" --embed-thumbnail --metadata-from-title \"%(artist)s - %(title)s\""

direnv hook fish | source
