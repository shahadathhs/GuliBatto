# Visual Design

## 1. Direction

The game should look like a carefully observed play area, not a glossy sci-fi marble simulator and not an exaggerated “exotic village” postcard. Aim for **grounded, tactile, readable, and modestly stylised**. Marbles provide the brightest colour and strongest specular highlights; the environment frames the shot without competing with it.

No human characters are required in the first release. The camera, hand-authored playing surface, marbles, markings, and sound can provide enough context.

## 2. Environment

### First arena

Build one compact, slightly irregular patch of packed earth with a clearly readable boundary. Start with geometry and materials that are inexpensive:

- ground plane with subtle, low-frequency dirt variation;
- a small amount of roughness/colour noise, not high-frequency visual clutter;
- simple low boundary stones or a shallow raised edge where needed;
- a readable pit/recess for the Guli Khela-inspired mode;
- restrained background props only if they help establish scale;
- a neutral horizon/background that makes the arena silhouette readable.

The playable area must remain obvious from top-down, angled, and low views. Avoid tall props near likely camera paths. If the Batto prototype uses a ring, make its boundary line unmistakable from every supported view.

## 3. Marbles

Marbles are the hero objects. Use enough surface detail to imply glass, clay, or polished stone without making the game heavy.

- Use a consistent sphere mesh/collider scale.
- Give each side a strong base colour plus a secondary pattern/mark so colour is not the only differentiator.
- Use a narrow specular highlight and a simple reflected environment impression; do not rely on costly screen-space effects.
- Keep the active striker identifiable through a subtle ring, marker, or outline that does not obscure its physical surface.
- Use distinct materials for striker versus target only when the distinction is clear at phone size.

Possible palette direction: warm earth browns and muted greens for the arena; contrasting blue, amber, jade, or red accents for marble sets. Final colours should be checked for contrast and colour-vision differences rather than fixed here as brand colours.

## 4. Lighting and rendering budget

The project targets Android and Web, so the design must work under the Godot Compatibility renderer.

- Start with one main directional or broad key light and restrained environment fill.
- Use contact-like grounding shadows where supported, but avoid depending on expensive shadow settings for object readability.
- Prefer simple materials over complex shaders.
- Keep post-processing minimal or absent until profiling proves it is affordable.
- Limit texture dimensions, material variants, particles, and decorative meshes.
- Test actual exported builds; the editor's rendering performance is not a reliable substitute for phone/browser profiling.
- Design a low-cost fallback that reduces shadows, effects, and background clutter while keeping marbles and boundaries readable.

Godot's Web export uses WebGL 2 with the Compatibility rendering method, so Forward+ or Mobile renderer-only features must not be required for the browser version. Reference: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html>.

## 5. Camera composition

- **Angled view (default):** see the active striker, most or all target marbles, boundaries, and any pit/goal at once.
- **Top-down:** maximise tactical clarity; avoid extreme perspective distortion.
- **Low view:** show the weight and roll of marbles, but constrain it to prevent the camera from clipping through the ground or walls. Treat this as an optional presentation view if it makes aiming harder.
- **Shot-follow:** follow the action briefly, with gentle easing and no disorienting whip movement. Return to a stable view when the board settles.

Use one camera rig with presets and continuous orbit controls. Camera perspective can make distance look different, so aim feedback should be computed in world space and projected to the ground, not inferred from screen pixels alone.

## 6. UI design

UI should resemble a small physical game kit: clear labels, simple rounded panels, warm neutrals, and high-contrast status colours. Keep it modern and uncluttered without using random ornamental motifs as a substitute for cultural research.

### Menu hierarchy

1. Start / Continue
2. Choose mode
3. Short “How to play” panel
4. Settings

### In-match hierarchy

- Active turn and current objective.
- Score or remaining target count.
- Aim power/direction feedback near the aiming context.
- Camera view/reset affordances in a consistent screen corner.
- Pause and restart controls.

Do not cover the playing surface with a large permanent panel. Keep HUD placements away from common touch/drag areas; the user must be able to orbit empty ground without brushing a button or firing a shot.

## 7. Motion and feedback

- Give marbles a short, readable rolling response and a modest collision sound matched to impact strength.
- Use particles sparingly: a little dust on a strong ground contact is enough; do not obscure the final positions.
- Use small UI confirmation for score/turn changes.
- Keep camera transitions eased and brief; let the player skip or disable action-follow if motion is uncomfortable.
- Never use an animation as the source of truth for a score. First evaluate rules from the settled board, then play the corresponding feedback.

## 8. Sound

Build a small, original or properly licensed sound set: marble click/roll, a stronger collision, a soft dirt contact, button feedback, and a concise score cue. Sound should help communicate weight and result, not become constant noise. Every critical result must also have a visual cue.

Do not use a recording of a real person's voice or a recognisable cultural performance without appropriate permission and licensing. Avoid implying authenticity through stock “village” sound effects.

## 9. Cultural visual integrity

Use observation and reference from real play areas if available. Ask permission before photographing or using identifiable people or private locations. Prefer specific, grounded details to generic visual clichés. If a local player explains a tool, layout, or customary marking, record what was learned and confirm whether it represents one locality or a broader practice.

## 10. Review checklist

Before accepting a visual change:

- Is the striker immediately recognisable?
- Can the player judge the edge/pit from every camera mode?
- Does the same board remain legible on a small phone screen?
- Does the material still read correctly with the low-cost settings?
- Are the camera and UI controls easy to reach without accidental shots?
- Does the change add meaning, or is it decoration that costs performance?
