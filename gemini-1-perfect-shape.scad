// Gemini-generated OpenSCAD script for Shogi Pieces
//
// This script generates a set of Shogi (Japanese chess) pieces suitable for 3D printing.
// You can generate a specific piece by name or all pieces at once.

// --- Parameters ---

// Name of the piece to generate. Set to "All" to generate all pieces.
// Available pieces: "Osho", "Gyokusho", "Hisha", "Kakugyo", "Kinsho", "Ginsho", "Keima", "Kyosha"
piece_to_generate = "All";

// --- Data ---

// Piece data derived from the provided 'piece-measurements.csv'.
// Format: [Name, Height (mm), Width (mm), Max Thickness (mm)]
PIECE_DATA = [
  ["Osho",     32.0, 28.7, 9.7],
  ["Gyokusho", 32.0, 28.7, 9.7],
  ["Hisha",    31.0, 27.7, 9.3],
  ["Kakugyo",  31.0, 27.7, 9.3],
  ["Kinsho",   30.0, 26.7, 8.8],
  ["Ginsho",   30.0, 26.7, 8.8],
  ["Keima",    29.0, 25.5, 8.3],
  ["Kyosha",   28.0, 23.5, 8.0]
];

// Angles from the provided reference images.
// These angles are consistent across all specified piece types.
ANGLE_FRONT_BOTTOM = 81;   // Angle at the base of the front pentagon.
ANGLE_FRONT_SIDE = 117;    // Angle at the "shoulder" of the pentagon.
ANGLE_FRONT_TOP = 144;     // Angle at the tip of the front pentagon (implicit in calculation).
ANGLE_SIDE_1 = 81;         // First angle of the side profile base.
ANGLE_SIDE_2 = 85;         // Second angle of the side profile base.


// --- Main Logic ---

// Find the index of the selected piece.
piece_index = -1;
for (i = [0:len(PIECE_DATA)-1]) {
  if (PIECE_DATA[i][0] == piece_to_generate) {
    piece_index = i;
  }
}

// Generate the selected piece or all pieces.
if (piece_to_generate == "All") {
  echo("Generating all Shogi pieces.");
  spacing = 35; // Space between pieces when generating all
  for (i = [0:len(PIECE_DATA)-1]) {
    translate([i * spacing, 0, 0]) {
      shogi_piece_from_index(i);
    }
  }
} else if (piece_index != -1) {
  echo("Generating piece:", piece_to_generate);
  shogi_piece_from_index(piece_index);
} else {
  echo("Error: Piece not found -", piece_to_generate);
  echo("Please choose from 'All', 'Osho', 'Gyokusho', 'Hisha', 'Kakugyo', 'Kinsho', 'Ginsho', 'Keima', 'Kyosha'.");
}


// --- Modules & Functions ---

// Module to generate a shogi piece by its index in the PIECE_DATA array.
module shogi_piece_from_index(index) {
  data = PIECE_DATA[index];
  name = data[0];
  height = data[1];
  width = data[2];
  thickness = data[3];

  shogi_piece(width, height, thickness);
}

// Core module to create a single Shogi piece.
// The piece is created by intersecting two extruded shapes:
// 1. The front-view pentagonal profile extruded along the Y-axis (thickness).
// 2. The side-view trapezoidal profile extruded along the X-axis (width).
// The piece is centered at the origin.
module shogi_piece(W, H, T) {
  intersection() {
    // Front Profile: A pentagon in the X-Z plane, extruded along Y.
    linear_extrude(height = T, center = true) {
      polygon(get_front_pentagon_points(W, H));
    }

    // Side Profile: A trapezoid in the Y-Z plane, extruded along X.
    // It's rotated into position to align with the Y-Z plane before extrusion.
    rotate([0, 90, 0]) {
      linear_extrude(height = W, center = true) {
        polygon(get_side_trapezoid_points(H, T));
      }
    }
  }
}

// Function to calculate the vertices of the front pentagon.
// The pentagon lies in the X-Z plane, centered horizontally.
// This calculation ensures all angles (81, 117 degrees) and dimensions (W, H) are respected.
// @param W The width of the base of the piece.
// @param H The total height of the piece.
// @return An array of 5 points defining the pentagon.
function get_front_pentagon_points(W, H) =
  let (
    // Angles of the vectors based on turtle-style drawing from the bottom-right corner.
    heading1 = 180 - ANGLE_FRONT_BOTTOM,               // Heading for the side flank (99 deg).
    heading2 = heading1 + (180 - ANGLE_FRONT_SIDE),    // Heading for the top flank (162 deg).

    // We solve a 2x2 system of linear equations to find the lengths of the
    // side flank (L1) and top flank (L2) based on the total width and height.
    // L1*cos(h1) + L2*cos(h2) = -W/2
    // L1*sin(h1) + L2*sin(h2) = H
    a = cos(heading1), b = cos(heading2), c = -W/2,
    d = sin(heading1), e = sin(heading2), f = H,

    // Solve for lengths L1 and L2 using Cramer's rule.
    det = a * e - b * d, // Determinant of the system.
    L1 = (c * e - b * f) / det,
    L2 = (a * f - c * d) / det,

    // Calculate the coordinates of the top-right "shoulder" point.
    p_br = [W/2, 0],
    p_tr_x = p_br[0] + L1 * cos(heading1),
    p_tr_z = p_br[1] + L1 * sin(heading1),

    // Define all 5 vertices of the pentagon using symmetry.
    p_bl = [-W/2, 0],
    p_tr = [p_tr_x, p_tr_z],
    p_top = [0, H],
    p_tl = [-p_tr_x, p_tr_z]
  )
  // Return points in order suitable for the polygon() function.
  [p_bl, p_br, p_tr, p_top, p_tl];

// Function to calculate the vertices of the side profile trapezoid.
// The trapezoid lies in the Y-Z plane, centered horizontally at the base.
// @param H The total height of the piece.
// @param T The maximum thickness (base width) of the piece.
// @return An array of 4 points defining the trapezoid.
function get_side_trapezoid_points(H, T) =
  let (
    // Calculate the top-left and top-right Y coordinates based on the base
    // angles, creating the non-symmetrical taper.
    y_tl = -T/2 + H / tan(ANGLE_SIDE_1),
    y_tr = T/2 - H / tan(ANGLE_SIDE_2),

    // Define the 4 vertices of the trapezoid.
    p_bl = [-T/2, 0],   // Bottom-left
    p_br = [T/2, 0],    // Bottom-right
    p_tr = [y_tr, H],   // Top-right
    p_tl = [y_tl, H]    // Top-left
  )
  // Return points in order for polygon().
  [p_bl, p_br, p_tr, p_tl];

