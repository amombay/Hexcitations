markerFamily = "DICT_4X4_50";
ids = 1:16;
markerSizePx = 300;
markerInches = 0.59;
nRows = 4;
nCols = 4;

figWidthIn = nCols * markerInches;
figHeightIn = nRows * markerInches;

imgs = generateArucoMarker(markerFamily, ids, markerSizePx);

fig = figure('Units','inches', 'Position',[1 1 figWidthIn figHeightIn], ...
             'PaperUnits','inches', 'PaperPosition',[0 0 figWidthIn figHeightIn], ...
             'Color','w');

for k = 1:numel(ids)
    col = mod(k-1, nCols);
    row = floor((k-1) / nCols);

    ax = axes('Parent', fig);
    set(ax, 'Units', 'normalized', ...
            'Position', [col/nCols, 1-(row+1)/nRows, 1/nCols, 1/nRows]);

    imshow(imgs(:,:,k), 'Parent', ax, 'Border','tight');
    axis(ax, 'image', 'off');
end

print(fig, 'aruco_1_16_0p59in.pdf', '-dpdf', '-r600');
