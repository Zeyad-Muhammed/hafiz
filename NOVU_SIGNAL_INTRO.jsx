#target aftereffects

// NOVU_SIGNAL_INTRO.jsx
// Generates a monochrome 2D "signal / transmission" brand ident for NOVU.
// Builds everything with native shape layers, text layers and keyframes.
// Safe to run multiple times - each run creates an incremented comp/folder.

var COL_BG    = [0.0196, 0.0196, 0.0196, 1];
var COL_WHITE = [1, 1, 1, 1];
var COL_GRAY  = [0.7216, 0.7216, 0.7216, 1];

var TCOL_W = [1, 1, 1, 1];
var TCOL_G = [0.7216, 0.7216, 0.7216, 1];

var WHITE_EXPR = "thisComp.layer('NOVU_CONTROLS').effect('Primary White')('Color')";
var BG_EXPR    = "thisComp.layer('NOVU_CONTROLS').effect('Background Color')('Color')";

// ---------------------------------------------------------------------------
// Generic helpers
// ---------------------------------------------------------------------------

function itemNameInUse(proj, nm) {
    for (var i = 1; i <= proj.numItems; i++) {
        var it = proj.item(i);
        if (it && it.name == nm) { return true; }
    }
    return false;
}

function uniqueItemName(base) {
    var proj = app.project;
    var name = base;
    var i = 2;
    while (itemNameInUse(proj, name)) {
        name = base + "_0" + i;
        i++;
    }
    return name;
}

function addShape(comp, layerName, startT) {
    var L = comp.layers.addShape();
    L.name = layerName;
    if (startT) { L.startTime = startT; }
    return L;
}

function OPN(l) { return l.property("ADBE Transform Group").property("ADBE Opacity"); }
function POS(l) { return l.property("ADBE Transform Group").property("ADBE Position"); }
function SCA(l) { return l.property("ADBE Transform Group").property("ADBE Scale"); }

function easeK(p, k) {
    try {
        p.setInterpolationTypeAtKey(k, KeyframeInterpolationType.EASE);
        p.setTemporalEaseAtKey(k, [new KeyframeEase(0, 66.6667)], [new KeyframeEase(0, 66.6667)]);
    } catch (e) {}
}

function holdK(p, k) {
    try { p.setInterpolationTypeAtKey(k, KeyframeInterpolationType.HOLD); } catch (e) {}
}

function fade(L, t0, v0, t1, v1) {
    var p = OPN(L);
    p.setValueAtTime(t0, v0);
    p.setValueAtTime(t1, v1);
    easeK(p, p.numKeys - 1);
    easeK(p, p.numKeys);
}

function addSlider(nl, nm, val) {
    var fx = nl.property("ADBE Effect Parade");
    var e = fx.addProperty("ADBE Slider Control");
    e.name = nm;
    try { e.property("ADBE Slider Control-0001").setValue(val); } catch (er) {}
}

function addColorCtrl(nl, nm, val) {
    var fx = nl.property("ADBE Effect Parade");
    var e = fx.addProperty("ADBE Color Control");
    e.name = nm;
    try { e.property("ADBE Color Control-0001").setValue(val); } catch (er) {}
}

function pickFont() {
    var prefs = [
        "Montserrat-Bold", "Montserrat",
        "HelveticaNeue-Bold", "Helvetica Neue Bold",
        "Helvetica-Bold", "Helvetica",
        "Arial-Bold", "ArialMT", "Arial"
    ];
    try {
        if (app.fonts && app.fonts.getFontByName) {
            for (var i = 0; i < prefs.length; i++) {
                try {
                    if (app.fonts.getFontByName(prefs[i])) { return prefs[i]; }
                } catch (e1) {}
            }
        }
    } catch (e2) {}
    return "Arial";
}

// ---------------------------------------------------------------------------
// Shape builders
// ---------------------------------------------------------------------------

function makeLinePath(v1, v2) {
    return {
        vertices: [v1, v2],
        inTangents: [[0, 0], [0, 0]],
        outTangents: [[0, 0], [0, 0]],
        closed: false
    };
}

function addLineGroup(layer, gname, v1, v2, sw) {
    var contents = layer.property("Contents");
    var grp = contents.addProperty("ADBE Vector Group");
    grp.name = gname;
    var g = grp.property("ADBE Vectors Group");
    var shp = g.addProperty("ADBE Vector Shape - Group");
    var pathP = shp.property("ADBE Vector Shape");
    pathP.setValue(makeLinePath(v1, v2));
    var stroke = g.addProperty("ADBE Vector Graphic - Stroke");
    var sc = stroke.property("ADBE Vector Stroke Color");
    sc.setValue(COL_WHITE);
    sc.expression = WHITE_EXPR;
    stroke.property("ADBE Vector Stroke Width").setValue(sw);
    return grp;
}

function addTrim(grp) {
    grp.property("ADBE Vectors Group").addProperty("ADBE Vector Filter - Trim");
}

function trimEndOf(grp) {
    return grp.property("ADBE Vectors Group").property("ADBE Vector Filter - Trim").property("ADBE Vector Trim End");
}

function pathPropOf(grp) {
    return grp.property("ADBE Vectors Group").property(1).property("ADBE Vector Shape");
}

function addRect(layer, gname, pos, w, h) {
    var contents = layer.property("Contents");
    var grp = contents.addProperty("ADBE Vector Group");
    grp.name = gname;
    var g = grp.property("ADBE Vectors Group");
    var rr = g.addProperty("ADBE Vector Shape - Rect");
    rr.property("ADBE Vector Rect Size").setValue([w, h]);
    rr.property("ADBE Vector Rect Position").setValue(pos);
    var fl = g.addProperty("ADBE Vector Graphic - Fill");
    var fc = fl.property("ADBE Vector Fill Color");
    fc.setValue(COL_WHITE);
    fc.expression = WHITE_EXPR;
    return rr;
}

function addDot(layer, gname, pos, size) {
    var contents = layer.property("Contents");
    var grp = contents.addProperty("ADBE Vector Group");
    grp.name = gname;
    var g = grp.property("ADBE Vectors Group");
    var el = g.addProperty("ADBE Vector Shape - Ellipse");
    el.property("ADBE Vector Ellipse Size").setValue([size, size]);
    el.property("ADBE Vector Ellipse Position").setValue(pos);
    var fl = g.addProperty("ADBE Vector Graphic - Fill");
    var fc = fl.property("ADBE Vector Fill Color");
    fc.setValue(COL_WHITE);
    fc.expression = WHITE_EXPR;
    return el;
}

// ---------------------------------------------------------------------------
// Text helpers
// ---------------------------------------------------------------------------

function addText(comp, nm, str, size, font, color, trackBase, startT) {
    var L = comp.layers.addText();
    L.name = nm;
    var doc = L.property("ADBE Text Document").value;
    doc.resetCharStyle();
    doc.resetParagraphStyle();
    doc.autoLeading = true;
    doc.text = str;
    doc.font = font;
    doc.fontSize = size;
    doc.fillColor = color;
    doc.justification = 2;
    L.property("ADBE Text Document").setValue(doc);
    L.label = 8;
    if (startT) { L.startTime = startT; }
    try {
        var tp = L.property("ADBE Text Properties");
        var an = tp.addProperty("ADBE Text Animator");
        an.name = "Track";
        var sel = an.property("ADBE Text Selectors").addProperty("ADBE Text Selector");
        var appr = an.property("ADBE Text Animator Properties");
        appr.addProperty("ADBE Text Tracking Type");
        var amt = appr.addProperty("ADBE Text Tracking Amount");
        amt.setValue(trackBase);
    } catch (e) {}
    return L;
}

function getTrackAmt(L) {
    try {
        return L.property("ADBE Text Properties").property("Track")
            .property("ADBE Text Animator Properties").property("ADBE Text Tracking Amount");
    } catch (e) { return null; }
}

function trackK(L, times, vals) {
    var amt = getTrackAmt(L);
    if (amt === null) { return; }
    for (var i = 0; i < times.length; i++) {
        amt.setValueAtTime(times[i], vals[i]);
        easeK(amt, amt.numKeys);
    }
}

// ---------------------------------------------------------------------------
// NOVU logo (editable shape layers, monochrome, symmetric)
// ---------------------------------------------------------------------------

function makeLogo(layer) {
    var res = { trims: [], dots: [] };
    res.trims.push(addLineGroup(layer, "NOVU_LOGO_MAIN_L", [-78, -110], [-78, 110], 11));
    addTrim(res.trims[res.trims.length - 1]);
    res.trims.push(addLineGroup(layer, "NOVU_LOGO_MAIN_R", [78, -110], [78, 110], 11));
    addTrim(res.trims[res.trims.length - 1]);
    res.trims.push(addLineGroup(layer, "NOVU_LOGO_CROSS", [-78, 110], [78, -110], 11));
    addTrim(res.trims[res.trims.length - 1]);
    res.trims.push(addLineGroup(layer, "NOVU_LOGO_TOP", [-140, -175], [140, -175], 3));
    addTrim(res.trims[res.trims.length - 1]);
    res.trims.push(addLineGroup(layer, "NOVU_LOGO_BOTTOM", [-80, 175], [80, 175], 3));
    addTrim(res.trims[res.trims.length - 1]);
    res.dots.push(addDot(layer, "NOVU_LOGO_DOTS_L", [-152, -175], 9));
    res.dots.push(addDot(layer, "NOVU_LOGO_DOTS_R", [152, -175], 9));
    res.dots.push(addDot(layer, "NOVU_LOGO_DOTS_C", [0, 215], 9));
    return res;
}

function popDot(elProp, t, size) {
    var p = elProp.property("ADBE Vector Ellipse Size");
    p.setValueAtTime(t, [0, 0]);
    p.setValueAtTime(t + 0.28, [size, size]);
    easeK(p, p.numKeys - 1);
    easeK(p, p.numKeys);
}

function animateLogoBuild(layer, res) {
    var ts = [0.25, 0.30, 0.45, 0.60, 0.70];
    for (var i = 0; i < res.trims.length; i++) {
        var te = trimEndOf(res.trims[i]);
        te.setValueAtTime(ts[i], 0);
        te.setValueAtTime(ts[i] + 0.45, 100);
        easeK(te, te.numKeys - 1);
        easeK(te, te.numKeys);
    }
    popDot(res.dots[0], 1.55, 9);
    popDot(res.dots[1], 1.65, 9);
    popDot(res.dots[2], 1.75, 9);
    var sc = SCA(layer);
    sc.setValueAtTime(0, [98, 98]);
    sc.setValueAtTime(2.4, [100.8, 100.8]);
    easeK(sc, sc.numKeys - 1);
    easeK(sc, sc.numKeys);
    try {
        var fb = layer.property("ADBE Effect Parade").addProperty("ADBE Fast Blur");
        var bl = fb.property("ADBE Fast Blur-0001");
        bl.setValueAtTime(0, 12);
        bl.setValueAtTime(1.35, 0);
        easeK(bl, bl.numKeys - 1);
        easeK(bl, bl.numKeys);
    } catch (e) {}
    var op = OPN(layer);
    op.setValueAtTime(0, 100);
    op.setValueAtTime(2.55, 100);
    op.setValueAtTime(2.95, 0);
    easeK(op, op.numKeys - 1);
    easeK(op, op.numKeys);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function main() {
    var proj = app.project;
    var name = uniqueItemName("NOVU_SIGNAL_INTRO");

    var folder = proj.items.addFolder(name);
    var comp = proj.items.addComp(name, 1920, 1080, 1, 15, 60);
    comp.parentFolder = folder;
    comp.workAreaStart = 0;
    comp.workAreaDuration = 15;
    comp.displayStartTime = 0;

    var font = pickFont();

    // 00 - NOVU_CONTROLS ----------------------------------------------------
    var ctrl = comp.layers.addNull();
    ctrl.name = "NOVU_CONTROLS";
    ctrl.label = 2;
    addSlider(ctrl, "Signal Intensity", 50);
    addSlider(ctrl, "Glitch Amount", 25);
    addSlider(ctrl, "Scan Speed", 50);
    addSlider(ctrl, "Logo Reveal", 50);
    addSlider(ctrl, "Text Reveal", 50);
    addSlider(ctrl, "Final Flicker", 40);
    addColorCtrl(ctrl, "Background Color", [0.0196, 0.0196, 0.0196, 1]);
    addColorCtrl(ctrl, "Primary White", [1, 1, 1, 1]);

    // 01 - BACKGROUND -------------------------------------------------------
    var bg = addShape(comp, "00_BG", 0);
    bg.label = 9;
    var bgG = bg.property("Contents").addProperty("ADBE Vector Group");
    bgG.name = "BG_RECT";
    var bgRec = bgG.property("ADBE Vectors Group").addProperty("ADBE Vector Shape - Rect");
    bgRec.property("ADBE Vector Rect Size").setValue([1920, 1080]);
    bgRec.property("ADBE Vector Rect Position").setValue([0, 0]);
    var bgF = bgG.property("ADBE Vectors Group").addProperty("ADBE Vector Graphic - Fill");
    bgF.property("ADBE Vector Fill Color").expression = BG_EXPR;

    // 02 - TEXTURE (subtle analog grain) ------------------------------------
    var tex = comp.layers.addSolid(COL_BG, "01_TEXTURE", 1920, 1080);
    tex.label = 16;
    try {
        var nz = tex.property("ADBE Effect Parade").addProperty("ADBE Noise2");
        nz.property("ADBE Noise2-0001").setValue(12);
    } catch (e) {}
    OPN(tex).setValue(8);

    // 03 - SIGNAL CORE POINT ------------------------------------------------
    var ptL = addShape(comp, "02_SIGNAL_CORE_POINT", 0);
    ptL.label = 13;
    addRect(ptL, "CORE_POINT", [0, 0], 6, 6);
    var pop = OPN(ptL);
    var ft = [0.08, 0.15, 0.22, 0.30, 0.38, 0.46, 0.54, 0.62, 0.72, 0.80,
              0.90, 1.00, 1.15, 1.30, 1.55, 1.80, 2.05, 2.30, 2.60];
    var fv = [45, 100, 30, 100, 20, 100, 55, 100, 30, 100,
              60, 100, 45, 100, 70, 100, 80, 100, 85];
    for (var pi = 0; pi < ft.length; pi++) {
        pop.setValueAtTime(ft[pi], fv[pi]);
        holdK(pop, pop.numKeys);
    }
    pop.setValueAtTime(3.0, 0);
    easeK(pop, pop.numKeys);

    // 04 - SIGNAL CORE LINES ------------------------------------------------
    var coreL = addShape(comp, "02_SIGNAL_CORE", 0);
    coreL.label = 13;
    var lr = addLineGroup(coreL, "CORE_LINE_R", [0, 0], [560, 0], 2);
    addTrim(lr);
    var ll = addLineGroup(coreL, "CORE_LINE_L", [0, 0], [-560, 0], 2);
    addTrim(ll);
    var teR = trimEndOf(lr);
    teR.setValueAtTime(0.45, 0);
    teR.setValueAtTime(1.8, 100);
    easeK(teR, teR.numKeys - 1);
    easeK(teR, teR.numKeys);
    var teL = trimEndOf(ll);
    teL.setValueAtTime(0.9, 0);
    teL.setValueAtTime(2.1, 100);
    easeK(teL, teL.numKeys - 1);
    easeK(teL, teL.numKeys);
    fade(coreL, 7.4, 100, 7.9, 0);

    // 05 - SCAN LINES --------------------------------------------------------
    var scn = addShape(comp, "03_SCAN_LINES", 0);
    scn.label = 11;
    var rows = [-380, -230, -90, 60, 210, 360];
    for (var si = 0; si < rows.length; si++) {
        var yy = rows[si];
        var left = addLineGroup(scn, "SCAN_L_" + (si + 1), [-620, yy], [-180, yy], 2);
        addTrim(left);
        var right = addLineGroup(scn, "SCAN_R_" + (si + 1), [180, yy], [620, yy], 2);
        addTrim(right);
        var t0 = 2.35 + si * 0.18;
        var sL = trimEndOf(left);
        sL.setValueAtTime(t0, 0);
        sL.setValueAtTime(t0 + 0.5, 100);
        easeK(sL, sL.numKeys - 1);
        easeK(sL, sL.numKeys);
        var sR = trimEndOf(right);
        sR.setValueAtTime(t0, 0);
        sR.setValueAtTime(t0 + 0.5, 100);
        easeK(sR, sR.numKeys - 1);
        easeK(sR, sR.numKeys);
    }
    var sop = OPN(scn);
    sop.setValueAtTime(1.9, 0);
    sop.setValueAtTime(2.05, 35);
    sop.setValueAtTime(2.15, 80);
    sop.setValueAtTime(2.35, 100);
    sop.setValueAtTime(2.55, 92);
    sop.setValueAtTime(2.75, 100);
    sop.setValueAtTime(7.3, 100);
    sop.setValueAtTime(7.85, 0);
    easeK(sop, 4); easeK(sop, 5); easeK(sop, sop.numKeys - 1); easeK(sop, sop.numKeys);
    for (var sk = 2; sk <= 3; sk++) { holdK(sop, sk); }
    var sp = POS(scn);
    sp.setValueAtTime(2.0, [960, 600]);
    sp.setValueAtTime(6.0, [960, 480]);

    // 06 - SIGNAL PARTICLES --------------------------------------------------
    var par = addShape(comp, "04_SIGNAL_PARTICLES", 2.2);
    par.label = 12;
    var parts = [
        [-460, -330, 150], [-400, -200, -120], [-320, -80, 180], [-260, 70, -140],
        [-180, 190, 150],  [-120, 300, -130],  [60, 320, 150],   [140, 210, -130],
        [220, 90, 170],    [300, -60, -140],   [380, -190, 120], [440, -320, -150]
    ];
    for (var pa = 0; pa < parts.length; pa++) {
        var px = parts[pa][0];
        var py = parts[pa][1];
        var po = parts[pa][2];
        var rectP = addRect(par, "PARTICLE_" + (pa + 1), [px, py], 5, 5);
        var rpos = rectP.property("ADBE Vector Rect Position");
        rpos.setValueAtTime(0, [px, py]);
        rpos.setValueAtTime(2.8, [px + po, py]);
    }
    var pop3 = OPN(par);
    pop3.setValueAtTime(0, 0);
    pop3.setValueAtTime(0.7, 100);
    pop3.setValueAtTime(0.9, 70);
    pop3.setValueAtTime(1.4, 100);
    pop3.setValueAtTime(2.0, 75);
    pop3.setValueAtTime(2.6, 100);
    holdK(pop3, 3); holdK(pop3, 5);
    pop3.setValueAtTime(5.4, 0);
    easeK(pop3, pop3.numKeys);

    // 07 - DECODING LINES -----------------------------------------------------
    var dec = addShape(comp, "05_DECODING_LINES", 2.2);
    dec.label = 11;
    var dl1 = addLineGroup(dec, "DECODE_VL", [-420, -560], [-420, 560], 3);
    addTrim(dl1);
    var dl2 = addLineGroup(dec, "DECODE_VR", [420, -560], [420, 560], 3);
    addTrim(dl2);
    var dl3 = addLineGroup(dec, "DECODE_HT", [-700, -400], [700, -400], 3);
    addTrim(dl3);
    var dl4 = addLineGroup(dec, "DECODE_HB", [-700, 400], [700, 400], 3);
    addTrim(dl4);

    var dk1 = trimEndOf(dl1);
    dk1.setValueAtTime(0.05, 0); dk1.setValueAtTime(0.45, 100);
    easeK(dk1, 1); easeK(dk1, 2);
    var dk2 = trimEndOf(dl2);
    dk2.setValueAtTime(0.15, 0); dk2.setValueAtTime(0.55, 100);
    easeK(dk2, 1); easeK(dk2, 2);
    var dk3 = trimEndOf(dl3);
    dk3.setValueAtTime(0.25, 0); dk3.setValueAtTime(0.65, 100);
    easeK(dk3, 1); easeK(dk3, 2);
    var dk4 = trimEndOf(dl4);
    dk4.setValueAtTime(0.35, 0); dk4.setValueAtTime(0.75, 100);
    easeK(dk4, 1); easeK(dk4, 2);

    var dp1 = pathPropOf(dl1);
    dp1.setValueAtTime(0.75, makeLinePath([-420, -560], [-420, 560]));
    dp1.setValueAtTime(2.4, makeLinePath([0, -560], [0, 560]));
    var dp2 = pathPropOf(dl2);
    dp2.setValueAtTime(0.75, makeLinePath([420, -560], [420, 560]));
    dp2.setValueAtTime(2.4, makeLinePath([0, -560], [0, 560]));
    var dp3 = pathPropOf(dl3);
    dp3.setValueAtTime(0.75, makeLinePath([-700, -400], [700, -400]));
    dp3.setValueAtTime(2.4, makeLinePath([-700, 0], [700, 0]));
    var dp4 = pathPropOf(dl4);
    dp4.setValueAtTime(0.75, makeLinePath([-700, 400], [700, 400]));
    dp4.setValueAtTime(2.4, makeLinePath([-700, 0], [700, 0]));

    fade(dec, 2.55, 100, 2.95, 0);

    // 08 - TECH LABELS ---------------------------------------------------------
    var l1 = addText(comp, "11_TECH_LABELS_TRANSMISSION", "TRANSMISSION // 001", 18, font, TCOL_G, 260, 0.9);
    POS(l1).setValue([170, 95]);
    fade(l1, 0, 0, 0.7, 45);
    fade(l1, 7.1, 45, 7.5, 0);

    var l2 = addText(comp, "11_TECH_LABELS_SIGNAL", "SIGNAL DETECTED", 16, font, TCOL_G, 320, 2.6);
    POS(l2).setValue([170, 135]);
    fade(l2, 0, 0, 0.7, 55);
    fade(l2, 5.4, 55, 5.8, 0);

    var l3 = addText(comp, "11_TECH_LABELS_DECODING", "DECODING", 16, font, TCOL_G, 340, 3.8);
    POS(l3).setValue([170, 175]);
    fade(l3, 0, 0, 0.7, 55);
    fade(l3, 4.2, 55, 4.6, 0);

    var l4 = addText(comp, "11_TECH_LABELS_NOVUSYSTEM", "NOVU SYSTEM", 18, font, TCOL_G, 280, 5.9);
    POS(l4).setValue([1750, 110]);
    fade(l4, 0, 0, 0.7, 60);
    fade(l4, 2.1, 60, 2.5, 0);

    // 09 - LOGO BUILD -----------------------------------------------------------
    var build = addShape(comp, "06_LOGO_BUILD", 5.0);
    build.label = 1;
    var buildRes = makeLogo(build);
    animateLogoBuild(build, buildRes);

    // 10 - LOGO FINAL (sharp, resolved + restrained glow) ------------------------
    var glowL = addShape(comp, "07_LOGO_FINAL_GLOW", 8.0);
    glowL.label = 5;
    makeLogo(glowL);
    try {
        var fbG = glowL.property("ADBE Effect Parade").addProperty("ADBE Fast Blur");
        fbG.property("ADBE Fast Blur-0001").setValue(26);
    } catch (e) {}
    fade(glowL, 0, 0, 0.9, 55);

    var finL = addShape(comp, "07_LOGO_FINAL", 8.0);
    finL.label = 1;
    makeLogo(finL);
    var fop = OPN(finL);
    fop.setValueAtTime(0, 0);
    fop.setValueAtTime(0.7, 100);
    easeK(fop, 1); easeK(fop, 2);
    var ft2 = [6.15, 6.22, 6.30, 6.38, 6.50];
    var fv2 = [100, 30, 100, 45, 100];
    for (var fk = 0; fk < ft2.length; fk++) {
        fop.setValueAtTime(ft2[fk], fv2[fk]);
        holdK(fop, fop.numKeys);
    }
    var fp = POS(finL);
    fp.setValueAtTime(6.10, [960, 540]);
    fp.setValueAtTime(6.18, [955, 540]);
    fp.setValueAtTime(6.28, [964, 540]);
    fp.setValueAtTime(6.36, [958, 540]);
    fp.setValueAtTime(6.50, [960, 540]);
    var fsc = SCA(finL);
    fsc.setValueAtTime(0, [100.8, 100.8]);
    fsc.setValueAtTime(0.9, [100, 100]);
    easeK(fsc, 1); easeK(fsc, 2);

    // 11 - FINAL GLITCH (ghost interference at the very end) ----------------------
    var glitch = addShape(comp, "12_FINAL_GLITCH", 13.9);
    glitch.label = 4;
    makeLogo(glitch);
    var gop = OPN(glitch);
    gop.setValueAtTime(0, 0);
    gop.setValueAtTime(0.12, 10); holdK(gop, gop.numKeys);
    gop.setValueAtTime(0.18, 0);  holdK(gop, gop.numKeys);
    gop.setValueAtTime(0.30, 7);  holdK(gop, gop.numKeys);
    gop.setValueAtTime(0.40, 0);  holdK(gop, gop.numKeys);
    gop.setValueAtTime(0.52, 12); holdK(gop, gop.numKeys);
    gop.setValueAtTime(0.60, 0);  holdK(gop, gop.numKeys);
    var gpos = POS(glitch);
    gpos.setValueAtTime(0, [962, 540]);
    gpos.setValueAtTime(0.15, [958, 540]);
    gpos.setValueAtTime(0.30, [963, 540]);
    gpos.setValueAtTime(0.45, [960, 540]);

    // 12 - NOVU WORDMARK ----------------------------------------------------------
    var wm = addText(comp, "08_NOVU_WORDMARK", "NOVU", 70, font, TCOL_W, 340, 8.3);
    POS(wm).setValue([960, 800]);
    var wop = OPN(wm);
    wop.setValueAtTime(0, 0);
    wop.setValueAtTime(0.8, 100);
    easeK(wop, 1); easeK(wop, 2);
    wop.setValueAtTime(5.95, 100); holdK(wop, wop.numKeys);
    wop.setValueAtTime(6.00, 45);  holdK(wop, wop.numKeys);
    wop.setValueAtTime(6.08, 100); holdK(wop, wop.numKeys);
    trackK(wm, [0, 1.2], [340, 130]);
    var wp = POS(wm);
    wp.setValueAtTime(0, [960, 792]);
    wp.setValueAtTime(1.2, [960, 800]);
    easeK(wp, 1); easeK(wp, 2);

    // 13 - MAIN MESSAGE ------------------------------------------------------------
    var head = addText(comp, "09_MAIN_MESSAGE", "BUILD WHAT'S NEXT.", 88, font, TCOL_W, 220, 10.0);
    POS(head).setValue([960, 940]);
    var hop = OPN(head);
    hop.setValueAtTime(0, 0);
    hop.setValueAtTime(0.9, 100);
    easeK(hop, 1); easeK(hop, 2);
    trackK(head, [0, 1.2], [220, 60]);
    var hp = POS(head);
    hp.setValueAtTime(0.2, [942, 940]);
    hp.setValueAtTime(1.1, [960, 940]);
    easeK(hp, 1); easeK(hp, 2);

    // 14 - SECONDARY MESSAGE --------------------------------------------------------
    var sec1 = addText(comp, "10_SECONDARY_MESSAGE", "WEBSITE + APPLICATIONS", 24, font, TCOL_G, 380, 10.9);
    POS(sec1).setValue([960, 1010]);
    fade(sec1, 0, 0, 0.5, 100);
    fade(sec1, 1.95, 100, 2.45, 0);
    trackK(sec1, [0, 0.7], [380, 260]);

    var sec2 = addText(comp, "10B_COMING_SOON", "COMING SOON", 18, font, TCOL_G, 480, 11.7);
    POS(sec2).setValue([960, 1052]);
    fade(sec2, 0, 0, 0.55, 100);
    fade(sec2, 1.15, 100, 1.65, 0);
    trackK(sec2, [0, 0.7], [480, 320]);

    // 15 - FINAL UNDERLINE -------------------------------------------------------------
    var ul = addShape(comp, "13_FINAL_UNDERLINE", 12.7);
    ul.label = 7;
    addLineGroup(ul, "UNDERLINE", [-95, 0], [95, 0], 2);
    fade(ul, 0, 0, 0.5, 100);

    // 16 - FADE TO BLACK --------------------------------------------------------------
    var fbo = comp.layers.addSolid([0, 0, 0, 1], "14_FADE_OUT", 1920, 1080);
    fbo.label = 16;
    fade(fbo, 14.4, 0, 14.95, 100);

    comp.openInViewer();
    app.project.activeItem = comp;
}

function run() {
    app.beginUndoGroup("NOVU_SIGNAL_INTRO Build");
    try {
        main();
    } catch (e) {
        alert("NOVU_SIGNAL_INTRO could not build.\n\nError: " + e.toString() + (e.line ? "\nLine: " + e.line : ""));
    } finally {
        try { app.endUndoGroup(); } catch (e2) {}
    }
}

run();