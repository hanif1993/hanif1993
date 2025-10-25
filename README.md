# SKILL Script: Hierarchical LPP Shape Remover

## Description

This repository contains a Cadence SKILL script designed to recursively find and delete all shapes on a specified Layer Purpose Pair (LPP) within a layout cell view. It's a powerful utility for cleaning up layout databases by removing unwanted or temporary geometry across an entire design hierarchy.

The script is designed to be safe, automatically skipping parameterized cells (pcells) and symbols to prevent corruption of your library components. After execution, it provides a clear summary of its actions by displaying a pop-up window that lists all the cells it has modified.

## Key Features

-   **Hierarchical Deletion:** Recursively searches and deletes shapes through a specified number of hierarchy levels.
-   **Targeted Cleaning:** Deletes shapes based on a specific Layer Purpose Pair (LPP), such as `list("METAL1" "drawing")`.
-   **Safe Operation:** Automatically detects and skips pcells and symbols to avoid damaging your standard cell libraries.
-   **User Feedback:** After running, a dialog box appears to report which cells have been modified. If no shapes were deleted, a message is displayed to confirm that no changes were made.
-   **Efficient Processing:** Uses a hash table to ensure that each unique shape is processed only once, even if it is instantiated multiple times.

## Requirements

-   A running session of Cadence Virtuoso.
-   A layout cell view to operate on.

## Installation

1.  Clone this repository or download the `CCSRemoveLppHierAll.il` file to your local machine.
2.  No further installation steps are needed. The script is ready to be loaded directly into Cadence Virtuoso.

## Usage

1.  **Load the Script:**
    In the Cadence Virtuoso Command Interpreter Window (CIW), use the `load` command to load the script file. You must provide the full path to the file:
    ```skill
    load("/path/to/your/folder/CCSRemoveLppHierAll.il")
    ```
    A successful load will return `t` in the CIW.

2.  **Open a Layout:**
    Open the layout cell view that you wish to modify. The script will automatically target the currently active layout window.

3.  **Execute the Procedure:**
    Call the `CCSRemoveLppHierAll` function from the CIW with the following arguments:
    ```skill
    CCSRemoveLppHierAll(LPP HierLevel)
    ```
    -   `LPP` (list): The Layer Purpose Pair to be processed.
    -   `HierLevel` (integer): The number of hierarchy levels to descend into.

    **Example:**
    To delete all shapes on the `"M1"` layer with the `"drawing"` purpose throughout the entire hierarchy, you would run:
    ```skill
    CCSRemoveLppHierAll(list("M1" "drawing") 100)
    ```
    *(Note: `100` is used here as a large number to ensure it traverses the full hierarchy of most designs.)*

4.  **Review the Results:**
    After the script finishes, a pop-up window will appear with either a list of the modified cells or a message stating that no shapes were deleted.

## Procedures Overview

### `CCSRemoveLppHierAll(LPP HierLevel @optional (cv geGetEditCellView()))`

-   The main function that orchestrates the shape deletion process.
-   It validates the input, searches for shapes, filters for uniqueness, deletes the shapes, and displays the final report.

### `CCSRemoveDuplicateElem(aList)`

-   A helper function that takes a list and returns a new list containing only the unique elements.
-   This is used to ensure that the script does not attempt to process the same cell view or shape multiple times, which prevents errors and improves efficiency.
