######################################################################
#
#     Juno Integration
#
######################################################################

@require Juno begin  # only if/when Juno is loaded

import Juno

function Juno.render(i::Juno.Inline, plt::VLSpec{:plot})
  checkplot(plt)
  tmppath = writehtml_full(JSON.json(plt.params))
  launch_browser(tmppath) # Open the browser
  Juno.render(i, nothing) # print nothing in the editor pane
end

# TODO : plotpane rendering
# # if package PhantomJS is present redirect rendering to Juno's plot pane
# try
#   import PhantomJS
#
#   Media.media(VegaLiteVis, Media.Plot)
#
#   Media.render(e::Atom.Editor, plt::VegaLiteVis) =
#     Media.render(e, nothing)
#
#   function Media.render(pane::Atom.PlotPane, plt::VegaLiteVis)
#     # write html to an IOBuffer()
#     pio = IOBuffer()
#     VegaLite.writehtml(pio, plt)
#     seekstart(pio)
#
#     # convert to png
#     png = PhantomJS.renderhtml(pio, clipToSelector=".marks", format="png")
#
#     Media.render(pane,
#                  Atom.div(
#                    Atom.img(src = "data:image/png;base64," * base64encode(png))))
#   end
# end


end