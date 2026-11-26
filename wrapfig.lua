-- Pandoc filter: a figure labelled wrap-l or wrap-r (see the wrapphoto
-- environment in posts) becomes a floated figure in the HTML.
function Figure(fig)
  -- \label{pair}: several photos side by side in one figure.
  -- \label{banner}: the full-bleed photo at the top of a post.
  local id = fig.attr.identifier
  if id == "pair" or id == "banner" then
    fig.attr.identifier = ""
    fig.attr.classes:insert(id)
    return fig
  end
  local side = fig.attr.identifier:match("^wrap%-([lr])$")
  if side then
    fig.attr.identifier = ""
    fig.attr.classes:insert("wrap")
    fig.attr.classes:insert(side == "l" and "wrap-left" or "wrap-right")
  end
  return fig
end
