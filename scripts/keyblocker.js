//key blocker. prevent cursor keys from scrolling page while playing cart.

function onKeyDown_blocker(event) {
	event = event || window.event;
	var o = document.activeElement;
	if (!o || o == document.body || o.tagName == "canvas")
	{
		if ([32, 37, 38, 39, 40].indexOf(event.keyCode) > -1)
		{
			if (event.preventDefault) event.preventDefault();
		}
	}
}

document.addEventListener('keydown', onKeyDown_blocker, false);