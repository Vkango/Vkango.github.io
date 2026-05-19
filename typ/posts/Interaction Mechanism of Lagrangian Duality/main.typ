#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#import "@preview/cetz:0.4.2": canvas
#import "@preview/fletcher:0.5.8": diagram, edge, node

#import cetz.draw: circle, content, line
#show: project.with(
  title: "Lagrange 对偶问题的互作机制",
  authors: (
    (
      name: "Vkango",
      email: "hivkan@outlook.com",
    ),
  ),
)

#set par(justify: true)
#set heading(numbering: "1.")

#set text(font: ("New Computer Modern", "Source Han Serif"))
#show math.equation: set text(font: ("New Computer Modern Math", "Source Han Serif"))

#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)

#set heading(numbering: "1.1.")
#let theorem = thmbox(
  "theorem",
  "Theorem",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let corollary = thmplain(
  "corollary",
  "Corollary",
  titlefmt: strong,
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let property = thmplain(
  "property",
  "Property",
  titlefmt: strong,
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let definition = thmbox(
  "definition",
  "Definition",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let problem = thmbox(
  "problem",
  "Problem",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)
#let thinking = thmbox(
  "thinking",
  "Thinking",
  inset: (top: 10pt, bottom: 10pt, left: 10pt, right: 10pt),
  radius: 0pt,
  stroke: (bottom: 1pt, top: 1pt),
)


// #title[Lagrange对偶问题的互作机制]

// 作者: Vkango, OpenAI GPT-5.4


= 引入

先看最常见的一类原始问题:

$
  min_x f(x) quad "s.t." quad g_i (x) <= 0, i=1,2,...,m
$

这里$f(x)$是目标函数, $g_i (x) <= 0$是不等式约束. 我们的目标是在可行域内选择$x$, 让$f(x)$尽可能小.

为了处理这些约束, 我们定义Lagrange函数:

$
  L(x, lambda) = f(x) + sum_(i=1)^m lambda_i g_i (x), quad lambda_i >= 0
$

在另一篇文章中, 我们从向量分解的角度理解了Lagrange乘子与KKT条件. 本文换一个角度: 把它看成一个*对抗过程*.

// #thinking[
//   对于一个理想的解, 则$g (x)<0$, 即$L(x,lambda)<f(x)$. 我们希望$L(x,lambda)$更贴近
// ]

// #thinking[
//   Lagrange函数本身不是最终目标. 它真正的作用是来定义下面的对偶函数: $ q(lambda)=inf_x L(x,lambda) $要说明固定一组$lambda$后, 让$x$把$L(x,lambda)$压到尽可能地低, 研究不同的$lambda$会给出什么样的结果.
// ]

#figure(
  align(center)[

    #diagram(
      node-stroke: .1em,
      spacing: 4em,
      node((0, 0), [$x$选择位置, \ 尽量压低$f(x)$]),
      node((1.5, 0), [试探约束漏洞, \ 可能出现$g_i (x)>0$]),
      node((1.5, 1.2), [$lambda$调整惩罚, 增大$lambda_i$]),
      node((0, 1.2), [$L(x,lambda)$被改写, \ 违规不再划算]),
      edge((0, 0), (1.2, 0), "-|>", [寻找更小值]),
      edge((1.5, 0), (1.5, 1.2), "-|>", [发现违规获利]),
      edge((1.2, 1.2), (0, 1.2), "-|>", [提高价格]),
      edge((0, 1.2), (0, 0), "-|>", [进入下一轮]),
    )],
  caption: [$x$ 负责试探能否通过违规降低代价, $lambda$ 负责提高这些违规方向的惩罚.],
)

直观来说, 和GAN网络很像, 是一种"对抗中协同进化"的过程:

- $x$ 总想把目标函数压得更低, 因此会不断尝试各种位置, 甚至包括违反约束的地方;

- $lambda$ 则像一套动态调整的惩罚机制, 哪里容易被 $x$ 用来"钻空子", 就提高哪里违规的代价.

Lagrange对偶构造出了一个*原变量与乘子的博弈结构*.



// = Lagrange函数的直观含义

// 对每个约束项$g_i (x)$:

// - 若$g_i (x) <= 0$, 说明约束满足, 此时$lambda_i g_i (x) <= 0$;

// - 若$g_i (x) > 0$, 说明约束违反, 此时$lambda_i g_i (x) > 0$.

// 因此:

// - 满足约束时, 加入到$f(x)$的是*非正项*.

// - 违反约束时, 加入到$f(x)$的是*正项*.

// 所以$lambda_i$可以理解成第$i$个约束的"惩罚力度".

// #thinking[满足约束时, Lagrange项可能让目标变小. 在这个场景中, $q(lambda)$成为原问题最优值的一个下界.]

= 一个简单的例子

假设原问题是:

$
  min_x f(x) quad "s.t." quad g(x) <= 0
$

对应的Lagrange函数为:

$
  L(x, lambda) = f(x) + lambda g(x), quad lambda >= 0
$

== 若$x$可行, 即$g(x) <= 0$

则

$
  L(x, lambda) = f(x) + lambda g(x) <= f(x)
$

因为此时$lambda g(x)<=0$. 所以对于可行点, Lagrange函数不会高于原目标值.

== 若$x$不可行, 即$g(x) > 0$

则

$
  L(x, lambda) = f(x) + lambda g(x) > f(x)
$

违反约束则解作废.
// #thinking[这里有一个重要现象, 如果某个$x$虽然违反了一点约束, 却能让$f(x)$降很多, 那么在固定的$lambda$下, 它仍然可能让$L(x,lambda)$更小.

//   这只能反馈出我们的$lambda$惩罚机制还不够成熟, 需要进一步迭代.]

我们下文主要讨论$x$是可行解的情况.

= 对偶函数

定义对偶函数:

$
  q(lambda) = inf_x L(x, lambda)
$

也就是:

$
  q(lambda) = inf_x (f(x) + sum_i lambda_i g_i (x))
$

定义$q(lambda)$时, 内层对$x$的优化不再显式要求$g_i (x) <= 0$.

#thinking[固定一组$lambda$后, $x$会在这套"惩罚规则"下, 把总代价$L(x, lambda)$压到尽可能低.

  这个$x$可能是可行的, 也可能是不可行的.]

// 前文提到的对抗性体现在这里了.

// 这正是“对抗性”的来源:

// - $x$负责试探系统漏洞;

// - $lambda$负责提高漏洞的代价.

// #thinking[
//   上面说了,  固定$lambda$后, $x$可以不管*原始约束*, 直接去*最小化*$L(x,lambda)$. 这听上去可能有些危险, 因为$x$可以违规.
// ]


#theorem[对于可行解 $x$, 则 $q(lambda)$ 都是原问题最优值的一个下界.]


// 设原问题最优值为:

// $
//   p^* = min f(x), quad "s.t." quad g_i (x) <= 0
// $

// 下面证明:

// $
//   q(lambda) <= p^*, quad forall lambda >= 0
// $

#proof[
  取任意一个*可行点*$x$, 则它满足$g_i (x) <= 0$, 且$lambda_i >= 0$.

  因此:

  $
    sum_i lambda_i g_i (x) <= 0
  $

  于是:

  $
    L(x, lambda) = f(x) + sum_i lambda_i g_i (x) <= f(x)
  $

  另一方面, 由于

  $
    q(lambda) = inf_x L(x, lambda) <= L(x, lambda)
  $

  所以:

  $
    q(lambda) <= L(x, lambda) <= f(x)
  $

  这对所有可行点$x$都成立, 自然也对最优可行点成立, 因此:

  $
    q(lambda) & <= p^*
  $

  其中, $p^*$是最优解, 即$p^* & = min f(x), quad "s.t." quad g_i (x) <= 0$.
]


下面我们的问题就是, 在$L(x,lambda)$提供的所有下界里, 找所有满足$x$为可行解的最高的那个, 即:

$
  max_(lambda >= 0) q(lambda)
$

- 内层: $x$ 试图压低$L(x,lambda)$.

- 外层, $lambda$ 试图抬高这个下界.



#figure(
  canvas(length: 0.8cm, {
    import cetz.draw: *

    // 坐标轴
    line((0, 0), (0, 6.2), mark: (end: ">"))
    line((0, 0), (8.2, 0), mark: (end: ">"))

    content((10.5, 0), [$lambda$ 的调整过程])
    content((0, 6.7), [值])

    // p*
    bezier((0.8, 5.2), (7.6, 6), (3, 4.3), stroke: (paint: red, thickness: 1.4pt))
    content((8.2, 6), [$p^*$])

    // q(lambda) levels
    line((1.2, 1.4), (2.6, 1.4), stroke: (paint: blue))
    content((3.5, 1.4), [$q(lambda_1)$])

    line((2.0, 2.5), (4.0, 2.5), stroke: (paint: blue))
    content((4.9, 2.5), [$q(lambda_2)$])

    line((3.2, 3.6), (5.6, 3.6), stroke: (paint: blue))
    content((6.55, 3.6), [$q(lambda_3)$])

    line((4.6, 4.5), (6.8, 4.5), stroke: (paint: blue))
    content((7.8, 4.5), [$q(lambda_4)$])

    // upward arrows
    line((2.2, 1.6), (2.2, 2.3), mark: (end: ">"), stroke: (paint: gray))
    line((3.6, 2.7), (3.6, 3.4), mark: (end: ">"), stroke: (paint: gray))
    line((5.0, 3.8), (5.0, 4.3), mark: (end: ">"), stroke: (paint: gray))
  }),
  caption: [对偶函数给出原问题最优值的下界; 调节 $lambda$ 的目标, 是把这个下界尽量抬高并逼近 $p^*$.],
)



= 原问题与对偶问题的关系

- 原问题在找可行解, 并尽量把$f(x)$往下压;

- 对偶问题在调节$lambda$, 并尽量把下界$q(lambda)$往上抬.

因此始终有:

$
  q(lambda) <= p^* <= f(x_"feasible")
$

其中, $q(lambda)$是对偶给出的下界; $p^*$是真实最优值; 右边是任一可行解给出的上界.

所以原问题与对偶问题之间, 存在一种很自然的"夹逼"关系:

- 一边找更好的可行解, 把上界往下压;

- 一边调更好的$lambda$, 把下界往上抬.

若两边最终靠拢, 就逼近了真实最优值.

= Lagrange对偶问题的求解

对偶问题写成:

$
  max_(lambda >= 0) q(lambda) = max_(lambda >= 0) inf_x L(x, lambda)
$

这可以理解为:

- 内层: 给定$lambda$, 让$x$去最小化$L$;

- 外层: 观察这个$x$有没有钻空子, 再调整$lambda$.

#thinking[如果某个$x$虽然违反了一点约束, 却能让$f(x)$降很多, 那么在固定的$lambda$下, 它仍然可能让$L(x,lambda)$更小.

  这只能反馈出我们的$lambda_i$惩罚力度还不够大, 于是应该给它调高.]

// 具体地说, 若当前某个约束$g_i (x) > 0$, 说明$x$在第$i$个方向上违反了约束. 这意味着当前的惩罚力度$lambda_i$还不够大, 于是应当把它调高.

反过来, 如果某个约束满足得很宽松, 即$g_i (x) < 0$, 那这个约束当前并不紧, 它的惩罚力度就没必要过高.

因此, 内层的$x$并不是最终答案本身, 它在指出*当前这套惩罚规则够不够严*.


#figure(
  canvas(length: 1.9cm, {
    import cetz.draw: *

    // Axis line
    line((1.5, 3.0), (9.5, 3.0), mark: (end: ">"))
    content((9.7, 3.0), [$x$])

    // divider
    line((5.5, 1.2), (5.5, 4), stroke: (paint: gray, thickness: 0.8pt))

    // labels
    content((3.4, 3.9), [可行区])
    content((3.4, 3.4), [$g(x) <= 0$])

    content((7.7, 3.9), [违规区])
    content((7.7, 3.4), [$g(x)>0$])

    // left side: L <= f
    content((3.4, 2.7), [$f(x)$])
    content((3.4, 1.5), [$L(x,lambda)=f(x)+lambda g(x)$])

    line((3.4, 2.5), (3.4, 1.7), mark: (end: ">"), stroke: (paint: blue))
    content((4.3, 2.1), [$lambda g(x) <= 0$])

    // right side: L > f
    content((7.8, 1.5), [$f(x)$])
    content((7.6, 2.7), [$L(x,lambda)=f(x)+lambda g(x)$])

    line((7.8, 1.7), (7.8, 2.5), mark: (end: ">"), stroke: (paint: red))
    content((8.7, 2.1), [$lambda g(x)>0$])

    // center labels
    content((5.5, 0.8), [边界：$g(x)=0$])
  }),
  caption: [Lagrange函数与$f(x)$在$x$不同情况下的大小情况],
)


// #thinking[
//   所以整个过程是:

//   + 固定$lambda$, 求一个让$L$尽量小的$x$;

//   + 观察这个$x$的约束违反情况;
//   + 根据违反程度调整$lambda$;
//   + 重复迭代.
// ]


= 弱对偶和强对偶

弱对偶: 无论怎么选择惩罚参数$lambda>=0$, 由它得到的函数值$q(lambda)$都不会超过原问题的最优值$p^*$.

强对偶: 在一些合适条件下, 对偶问题能找到的最高下界, 恰好就是原问题的最优解.

弱对偶基本上总是成立的, 但是强对偶不总是成立. 对偶问题只能逼近到某个程度, 可能碰不到真正的最优值.

#figure(
  canvas(length: 0.85cm, {
    import cetz.draw: *

    // axes
    line((0, 0), (0, 6), mark: (end: ">"))
    line((0, 0), (8.2, 0), mark: (end: ">"))

    content((8.45, -0.1), [$lambda$])
    content((-0.15, 6.5), [值])

    // dual curve-like polyline
    line((0.8, 1.2), (1.8, 2.2), stroke: (paint: blue))
    line((1.8, 2.2), (3.0, 3.1), stroke: (paint: blue))
    line((3.0, 3.1), (4.3, 3.8), stroke: (paint: blue))
    line((4.3, 3.8), (5.3, 4.1), stroke: (paint: blue))
    line((5.3, 4.1), (6.2, 4.0), stroke: (paint: blue))

    content((6.9, 4.0), [$q(lambda)$])

    // p*
    line((0.7, 5.0), (7.4, 5.0), stroke: (paint: red, thickness: 1.3pt))
    content((7.75, 5.0), [$p^*$])

    // max q
    line((5.3, 4.1), (5.3, 0), stroke: (paint: gray))
    content((5.3, -0.35), [$lambda^*$])

    // note
    content((4.5, 6.5), [$ max_{lambda>=0} q(lambda)<= p^* $])
  }),
  caption: [弱对偶: 无论怎样选择 $lambda>=0$, 对偶函数的值都不会超过原问题最优值.],
)



= 对偶梯度更新公式

设对当前$lambda$, 内层最优点为:

$
  x^*(lambda) = arg min_x L(x, lambda)
$

则

$
  q(lambda) = L(x^*(lambda), lambda)
$

由于

$
  L(x, lambda) = f(x) + sum_i lambda_i g_i (x)
$

对$lambda_i$求偏导得:

$
  (partial L)/(partial lambda_i) = g_i (x)
$

因此, 在较好条件下, 对偶函数的梯度满足:

$
  (partial q)/(partial lambda_i) = g_i (x^*(lambda))
$


#theorem[对偶函数沿第$i$个方向该怎么调整, 就取决于当前内层最优点对第$i$个约束违反了多少. ]

于是就得到常见的对偶上升更新:

$
  lambda_i^(k+1) = lambda_i^k + alpha_k g_i (x^k)
$

再考虑非负约束$lambda_i >= 0$, 通常写成投影形式:

$
  lambda_i^(k+1) = max(0, lambda_i^k + alpha_k g_i (x^k))
$

其中:

$
  x^k = arg min_x L(x, lambda^k)
$

这个类似生物学上的反馈调节:

- 若$g_i (x^k) > 0$, 说明违反约束, 增大$lambda_i$;

- 若$g_i (x^k) < 0$, 说明约束宽松, 可减小$lambda_i$;
- 若$g_i (x^k) = 0$, 说明正好卡在边界.

= 预期结果: 鞍点

如果一切理想, 最终会到达某个点$(x^*, lambda^*)$, 满足:

$
  L(x^*, lambda) <= L(x^*, lambda^*) <= L(x, lambda^*)
$

这就是Lagrange函数的鞍点. $ L(x,lambda)=f(x)+sum_i lambda_i g_i (x) $

它的意义是:

- 固定$lambda^*$, $x^*$让$L$最小.

- 固定$x^*$, $lambda^*$让$L$最大.

所以整个结构可以写成:

$
  min_x max_(lambda >= 0) L(x, lambda)
$

或从对偶角度写成:

$
  max_(lambda >= 0) min_x L(x, lambda)
$

当这两者能对上时, 原问题和对偶问题就达成了一致.

= 和KKT条件的关系

如果原问题足够好, 例如:

- $f$与$g_i$是凸的;

- 满足适当的约束资格条件.

那么原问题最优解与对偶最优解之间会满足 KKT 条件.

对不等式约束情形, KKT 条件包括:

1. *原始可行性*
  $
    g_i(x^*) <= 0
  $

2. *对偶可行性*
  $
    lambda_i^* >= 0
  $

3. *互补松弛*
  $
    lambda_i^* g_i(x^*) = 0
  $

4. *驻点条件*
  $
    nabla f(x^*) + sum_i lambda_i^* nabla g_i(x^*) = 0
  $

这四条正好对应前面的对抗图景:

- 原始可行性: 最终的$x^*$必须回到可行域;

- 对偶可行性: 惩罚力度不能为负;

- 互补松弛: 不紧的约束不该保留正价格, 真正起作用的约束才会"顶住边界";

- 驻点条件: 在最优点处, 目标下降方向与活跃约束的法向方向达到平衡.


Lagrange 对偶可以理解为一个双层过程:

- 内层的$x$在当前惩罚规则下, 尽量把总代价压低;

- 外层的$lambda$根据约束违反程度, 不断调整惩罚力度.

于是:

- 原问题负责给出上界;

- 对偶问题负责抬高下界;
- 两者在良好条件下会通过鞍点与 KKT 条件统一起来.
