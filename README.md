# Shaderize your flutters.

## Getting started

Use Flutter 3.7 or later, and follow [this guide](https://docs.flutter.dev/development/ui/advanced/shaders).

## How to use
1. In your code, prepare a `Shady` instance with details about the shader program. It's important to add *all* uniforms and texture samplers, and to add them in *the same order* as they appear in the shader program.

    ```
    /* assets/shaders/myShader.frag */

    uniform float uniformOne;
    uniform float uniformTwo;
    uniform sampler2D textureOne;

    [...]
    ```

    ```
    /* Flutter code */

    final shady = Shady(
      assetName: 'assets/shaders/myShader.frag',
      uniforms: [
        UniformFloat(key: 'uniformOne'),
        UniformFloat(key: 'uniformTwo'),
      ],
      samplers: [
        TextureSampler(
          key: 'textureOne',
          asset: 'assets/texture1.png',
        ),
      ],
    );

    [...]
    ```
2. When appropriate, load the shader program.
    ```
    await shady.load();
    ```
3. Use one of the supplied widgets where you want to display your shader.
    ```
    SizedBox(
      width: 200,
      height: 200,
      child: ShadyCanvas(shady),
    ),
    ```
4. Modify your shader parameters by using your `Shady` instance
    ```
    shady.setUniform<double>('uniformOne', 0.4);
    shady.setTexture('textureOne', 'assets/texture2.png');
    ```

## Other features

#### Transformers

Transformers are callbacks that are called every frame to transform a uniform value using the previous value and a delta time.

```
  ShadyUniformFloat(
    key: 'uniformOne',
    transformer: (previousValue, deltaDuration) {
      return previousValue + (deltaDuration.inMilliseconds / 1000);
    },
  )
```

There are some common premade transforms available as static members on the `Uniform*` classes.

```
  // This is equivalent to the above snippet

  ShadyUniformFloat(
    key: 'uniformOne',
    transformer: ShadyUniformFloat.secondsPassed,
  )
```

Transformers can be switched.

```
  shady.setTransformer(
    'uniformOne',
    (previousValue, deltaDuration) {
      // Let's go twice as fast!
      return previousValue + ((deltaDuration.inMilliseconds / 1000) * 2);
    },
  );
```

#### Using ShaderToy shaders

[ShaderToy](https://www.shadertoy.com/) is an awesome playground for GLSL experimentation. However, both it and Flutter have some quirks and magic in how shaders are written.

To use a ShaderToy shader (with some limitations), wrap it like this:
```
#include <flutter/runtime_effect.glsl>
uniform vec3 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform vec4 iMouse;
out vec4 fragColor;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
////////////// Shadertoy BEGIN

[ Paste your Shadertoy code here ]

////////////// Shadertoy END
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
```

Then, when creating your `Shady` instance, flag it using the parameter `shaderToy` to automatically add and wire the ShaderToy uniforms. The supported uniforms will then automatically be updated the same way as they are on ShaderToy.

```
Shady(
  assetName: 'assets/shaders/myShaderToyShader.frag'),
  shaderToy: true,
)
```

Only the ShaderToy uniforms listed are supported, and the only supported data type for channels is 2D textures (`sampler2D`).


#### Interactive shaders

Shady includes a convenience widget for interactive shaders. It will wire interactions to selected uniforms and give you callbacks for interception.

```
ShadyInteractive(
  shady,

  // Will get normalized coordinates of interactions
  uniformVec2Key: 'inputCoord',

  // A callback that is called on interaction
  onInteraction: (coord) => print('Was interacted at $coord'),
)
```

A Shady that has been flagged as `shaderToy` will have the `iMouse` uniform automatically wired.

## Additional information

The `example` app has a gallery of various shaders. Have a look for inspiration and such.