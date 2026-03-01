# Shogi 3D Print

![Shogi Pieces Circle](IMG_circle.jpeg)

This project is an effort to model Shogi (Japanese Chess) game pieces for 3D printing using OpenSCAD. The goal is to generate accurately shaped pieces with recessed Kanji characters for multi-material printing.

## Usage

The `gemini.scad` file is a fully parametric OpenSCAD script designed for high-quality Shogi piece generation. 

### Key Features & Configurability

You can customize the following parameters in the OpenSCAD Customizer:

*   **Piece Selection:** Choose specific pieces (e.g., `Osho`, `Gyokusho`, `Fuhyo`) or render `All` pieces at once.
*   **Multi-Material Workflow:** 
    *   **Part to Render:** Select between the `Piece Body`, `Unpromoted Text (Black)`, or `Promoted Text (Red)` for separate STL/3MF exports.
    *   **Assembly (Preview):** View the fully assembled piece with colored text for design verification.
*   **Geometric Adjustments:**
    *   **Create Recesses:** Toggle between a solid body (for multi-material merging) or a body with subtracted recesses (for single-color printing or "negative volume" slicer modifiers).
    *   **Sanding Offset:** Add a uniform material offset (e.g., `0.2mm`) to the body to allow for post-print sanding without losing the sharp edges of the Kanji.
    *   **Text Depth & Positioning:** Fine-tune `text_recess_depth` and `text_vertical_adjust` to ensure perfect legibility.
*   **Typography:**
    *   **Font Choice:** Select from over 14 pre-defined Japanese font styles (e.g., *Shippori Mincho*, *Hina Mincho*).
    *   **Render All Fonts:** A debug mode that renders the entire set of pieces across all available fonts for visual comparison.
    *   **Kanji Spacing:** Adjust the `two_char_vertical_spacing_factor` to optimize the layout of multi-character names like *Kinsho* or *Ginsho*.

### 3D Printing Workflow

#### For Multi-Color Printing
1.  Export the **Piece Body** (with `create_recesses = false`).
2.  Export the **Unpromoted Text** and **Promoted Text** as separate files.
3.  Load all parts into your slicer (PrusaSlicer, Bambu Studio, etc.), select them, and use the **Merge/Assemble** command.
4.  Assign different filaments to each part.

#### For Single-Color Printing (Recessed)
1.  Set `create_recesses = true`.
2.  Export the **Piece Body**. The resulting STL will have the Kanji subtracted directly from the mesh.

## Design Guides and Data Source

The design of these pieces is based on the following visual and dimensional guides:

*   **Front View:** `front-view.png`
*   **Side View:** `side-view.png`
*   **Measurements:** `measurements.csv`

The dimensional data and general design guidance were sourced from [Shogi.cloud/misure](https://www.shogi.cloud/misure/).

## Example Renders

Here are examples of the generated Shogi pieces:

### Front View Example

![Front View Example](img-front.jpeg)

### Side View Example

![Side View Example](img-side.jpeg)

## Gallery

| | |
|:---:|:---:|
| ![Osho](IMG_osho.jpeg) | ![Side View](IMG_side.jpeg) |
| ![Regular Pieces](IMG_regular.jpeg) | ![Promoted Pieces](IMG_promoted.jpeg) |
| ![Side Stand](IMG_side_stand.jpeg) | ![On Board](IMG_onboard.jpeg) |
| ![On Board Promoted](IMG_onboard_promoted.jpeg) | |
