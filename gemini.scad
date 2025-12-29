// Gemini-generated OpenSCAD script for Shogi Pieces
//
// ======== HOW TO USE FOR 3D PRINTING ========
// This script generates separate parts for multi-material printing.
// Your 3D slicer (e.g., PrusaSlicer, Bambu Studio, Cura) will combine the parts.
//
// --- For Multi-Color Printing ---
// 1. Select "Piece Body (Solid)" from `part_to_render` and export as STL/3MF.
// 2. Select "Unpromoted Text (Black)" and export as a separate file.
// 3. Select "Promoted Text (Red)" and export as a separate file.
// 4. In your slicer, load all parts. They may appear separated.
// 5. Select all parts and use the "Assemble" or "Merge" command. They will snap into place.
// 6. Assign your main filament (e.g., wood) to the body and other colors to the text parts.
//
// --- For Single-Color Printing (with recessed text) ---
// 1. Select "Piece Body (Solid)" and export.
// 2. Select "Unpromoted Text (Black)" and export.
// 3. Select "Promoted Text (Red)" and export.
// 4. In your slicer, load all parts and assemble them.
// 5. Select the two text parts and mark them as "Negative Volume" or "Cutter".
// 6. This will subtract the text from the body, creating perfect recesses.
//
// =================================================

// --- Parameters ---
piece_to_generate = "All"; // ["All", "Osho", "Gyokusho", "Hisha", "Kakugyo", "Kinsho", "Ginsho", "Keima", "Kyosha", "Fuhyo"]

// --- Customization ---
part_to_render = "Assembly (Preview)"; // ["Assembly (Preview)", "Piece Body (Solid)", "Unpromoted Text (Black)", "Promoted Text (Red)"]
text_vertical_adjust = 0; // [-5:0.1:5]
font_name = "Noto Sans JP";

// --- Data ---
PIECE_DATA = [
  ["Osho",32.0,28.7,9.7],["Gyokusho",32.0,28.7,9.7],["Hisha",31.0,27.7,9.3],["Kakugyo",31.0,27.7,9.3],
  ["Kinsho",30.0,26.7,8.8],["Ginsho",30.0,26.7,8.8],["Keima",29.0,25.5,8.3],["Kyosha",28.0,23.5,8.0],
  ["Fuhyo",27.0,22.0,7.5]
];
KANJI_DATA = [
  ["Osho","王將",""],["Gyokusho","玉將",""],["Hisha","飛車","龍王"],["Kakugyo","角行","龍馬"],["Kinsho","金將",""],
  ["Ginsho","銀將","成銀"],["Keima","桂馬","成桂"],["Kyosha","香車","成香"],["Fuhyo",    "歩兵", "と金"]
];
ANGLE_FRONT_BOTTOM=81; ANGLE_FRONT_SIDE=117; ANGLE_SIDE_1=81; ANGLE_SIDE_2=85;

// --- Main Logic ---

// Function to find the index of a piece by name using a list comprehension.
// This is the robust way to search in OpenSCAD, avoiding variable scope issues.
function find_piece_index(name) = [
  for (i = [0:len(PIECE_DATA)-1]) if (PIECE_DATA[i][0] == name) i
];

if (piece_to_generate == "All") {
  // If "All" is selected, loop through and render every piece.
  spacing = 35;
  for (i = [0 : len(PIECE_DATA) - 1]) {
    translate([i * spacing, 0, 0]) {
      shogi_piece_from_index(i);
    }
  }
} else {
  // If a single piece is selected, find its index using the function.
  indices = find_piece_index(piece_to_generate);
  
  if (len(indices) > 0) {
    // If found, render the piece at the first matching index.
    shogi_piece_from_index(indices[0]);
  } else {
    // If not found, show an error.
    echo("Error: Piece not found.");
  }
}

// --- Modules & Functions ---
module shogi_piece_from_index(index) {
  d=PIECE_DATA[index]; k=KANJI_DATA[index];
  shogi_piece(H=d[1],W=d[2],T=d[3],kanji_unpromoted=k[1],kanji_promoted=k[2]);
}

module shogi_piece(W, H, T, kanji_unpromoted, kanji_promoted) {
  // This internal module creates the text geometry, rotated, at the origin.
  module text_geometry_at_origin(is_promoted) {
    txt = is_promoted ? kanji_promoted : kanji_unpromoted;
    if (txt != "") {
      text_depth = T * 0.45;
      face_angle = is_promoted ? ANGLE_SIDE_1 : ANGLE_SIDE_2;
      rotate_angle = 90 - face_angle;
      direction = is_promoted ? -1 : 1;
      
      // Corrected rotation:
      // 1. Rotate 90 around X to make text stand upright (from XY to XZ plane).
      // 2. Rotate `direction * rotate_angle` around Y to tilt text parallel to the face.
      rotate([90, 0, 0]) { // Make text upright
        rotate([0, direction * rotate_angle, 0]) { // Tilt to match face angle
          // Extrude from z=0 down to z=-text_depth in the rotated coordinate system.
          translate([0, 0, -text_depth]) {
            linear_extrude(height = text_depth) {
              // --- Vertical Text and Sizing Logic ---
              if (len(txt) == 2) {
                size = H * 0.3; spacing = size * 0.55;
                translate([0,spacing,0]) text(str(txt[0]),size=size,font=font_name,halign="center",valign="center");
                translate([0,-spacing,0]) text(str(txt[1]),size=size,font=font_name,halign="center",valign="center");
              } else {
                size = H * 0.35;
                text(txt,size=size,font=font_name,halign="center",valign="center");
              }
            }
          }
        }
      }
    }
  }

  // Calculate the final [x,y,z] position for the text objects.
  z_pos = (H / 2.1) + text_vertical_adjust;
  y_front = z_pos*(-1/tan(ANGLE_SIDE_2))+T/2;
  y_back = z_pos*(1/tan(ANGLE_SIDE_1))-T/2;
  pos_front = [0, y_front, z_pos];
  pos_back = [0, y_back, z_pos];

  // Render the selected part.
  if (part_to_render == "Assembly (Preview)") {
    // Show the solid body with the text parts overlapping.
    // Use transparency to see how they fit.
    color("goldenrod", 0.5) piece_body(W, H, T);
    color("black") translate(pos_front) text_geometry_at_origin(false);
    color("red") translate(pos_back) text_geometry_at_origin(true);
  } else if (part_to_render == "Piece Body (Solid)") {
    piece_body(W, H, T);
  } else if (part_to_render == "Unpromoted Text (Black)") {
    translate(pos_front) text_geometry_at_origin(false);
  } else if (part_to_render == "Promoted Text (Red)") {
    translate(pos_back) text_geometry_at_origin(true);
  } else if (part_to_render == "Piece Body with Recesses") {
    // This is for preview only and may fail to render due to CGAL errors.
    // For printing, export the solid body and text parts separately.
    difference() {
        piece_body(W,H,T);
        translate(pos_front) text_geometry_at_origin(is_promoted = false);
        translate(pos_back) text_geometry_at_origin(is_promoted = true);
    }
  }
}

// Generates the solid outer body of the shogi piece using a polyhedron.
// This method is robust and creates a clean, manifold mesh suitable for 3D printing.
module piece_body(W, H, T) {
  // 1. Get the 5 points of the 2D front pentagon profile.
  p_pts = get_front_pentagon_points(W, H);

  // 2. Define the Y-coordinates for the front and back faces at different heights.
  //    The thickness profile is a trapezoid, so the Y position is a linear
  //    function of the Z-height.
  function y_pos(z, is_promoted_face) = is_promoted_face
      ? z * (1 / tan(ANGLE_SIDE_1)) - T / 2  // Back face
      : z * (-1 / tan(ANGLE_SIDE_2)) + T / 2; // Front face

  // 3. Create the 10 vertices of the 3D shape.
  //    v_f_* are front vertices, v_b_* are back vertices.
  points = [
    // Back vertices (indices 0-4)
    for (p = p_pts) [p[0], y_pos(p[1], true), p[1]],
    // Front vertices (indices 5-9)
    for (p = p_pts) [p[0], y_pos(p[1], false), p[1]]
  ];

  // 4. Define the faces connecting the vertices.
  //    Each face is a list of vertex indices. Order matters for correct orientation.
  faces = [
    [0, 4, 3, 2, 1],      // Back face (reversed winding order)
    [5, 6, 7, 8, 9],      // Front face
    [0, 1, 6, 5],         // Bottom face
    [1, 2, 7, 6],         // Right side face
    [2, 3, 8, 7],         // Top-right face
    [3, 4, 9, 8],         // Top-left face
    [4, 0, 5, 9]          // Left side face
  ];

  // 5. Create the polyhedron.
  polyhedron(points = points, faces = faces);
}
function get_front_pentagon_points(W,H)=let(h1=180-ANGLE_FRONT_BOTTOM,h2=h1+(180-ANGLE_FRONT_SIDE),
a=cos(h1),b=cos(h2),c=-W/2,d=sin(h1),e=sin(h2),f=H,det=a*e-b*d,L1=(c*e-b*f)/det,L2=(a*f-c*d)/det,
p_br=[W/2,0],p_tr_x=p_br[0]+L1*cos(h1),p_tr_z=p_br[1]+L1*sin(h1),p_bl=[-W/2,0],
p_tr=[p_tr_x,p_tr_z],p_top=[0,H],p_tl=[-p_tr_x,p_tr_z])[p_bl,p_br,p_tr,p_top,p_tl];

function get_side_trapezoid_points(H,T)=let(y_b=-T/2+H/tan(ANGLE_SIDE_1),y_f=T/2-H/tan(ANGLE_SIDE_2),
p_bl=[-T/2,0],p_br=[T/2,0],p_tr=[y_f,H],p_tl=[y_b,H])[p_bl,p_br,p_tr,p_tl];