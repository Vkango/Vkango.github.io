#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": proof, theorem
#import pages: *
#import "@preview/cetz:0.4.2"
#show: project.with(
  title: "漫游 Optimizers",
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
  base: "theorem",
  titlefmt: strong,
)
#let definition = thmbox(
  "definition",
  "Definition",
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

#let redit(body) = text(weight: "bold", fill: red, body)
#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

// #set page(footer: [Copyleft #math.copyleft 2026 Vkango. CC-BY-SA-4.0 License.], header: align(
//   right,
//   link("https://vkango.top"),
// ))

// #title[漫游 Optimizers]



_Welcome home. Consider this an odyssey of the mind._

这是一个头脑风暴文章, 目的是拓宽视野, 将多个领域知识穿插理解, 可能并不严谨.

#v(50pt)

想了想, 还是决定给优化器好好理解一下. 直接调用PyTorch的命令还是觉得不知道原理是什么.

其实我觉得大概率我写完了之后, 我也还是会在选择什么优化器上使用试错法. 不过现在写完看来, 中途还是有挺多收获的, 真不白看啊, 亲们.

= 任务

== 数据集

训练模型这件事情, 通常会被写成下面这个形式:$ min_theta F(theta)=1/N sum_(i=1)^N cal(l)_i (theta) $

其中, $theta$ 是模型参数, $N$ 是训练样本数, $cal(l)_i (theta)$ 表示模型在第 $i$ 个样本上的损失.

在监督学习里通常是:$ cal(l)_i (theta)=cal(l)(f_theta (x_i),y_i) $

给定一组训练样本 $(x_i,y_i)$, 希望找到一组参数 $theta$, 使得模型 $f_theta$ 在这些样本上的平均损失尽可能小.

#thinking[
  我们关心的并不是*训练集上的平均 Loss 最小*. 而是泛化能力, 即在未见过的数据上仍然表示良好.
]


记真实数据分布为 $cal(D)$, 理论上更自然的目标就是最小化*总体风险*:$ R(theta)=EE_((x,y)~cal(D))[cal(l)(f_theta (x),y)] $

希望模型在*真实分布*上的平均损失尽可能小. 显然, $cal(D)$ 往往未知. 我们手里只有有限样本, 因此只能把总体风险替换为经验风险, 即:$ hat(R)(theta)=F(theta) $

在训练时做不到最小化泛化能力本身, 因此我们用一个训练集构造出来的分布来去近似真实的分布, 并让模型在这个分布上性能最好.

== 训练目标

那这个 $cal(l)$ 如何去定义?

在分类任务中, 我们最自然的想法是最大化精度:$ max_theta F(theta)=max_theta 1/N sum_(i=1)^N redit(1)[f_theta (x_i)=y_i] $

等价地, 也可以写成最小化分类错误率:$ min_theta F(theta)=min_theta 1/N sum_(i=1)^N redit(1)[f_theta (x_i)!=y_i] $

这看起来非常合理, 任务关心什么, 我们就优化什么. 但是问题恰好出现在这里: 分类精度本质上依赖的是*预测类别有没有变对*, 而不是*概率预测往正确方向移动了多少*.

// - 它几乎处处不可导, 或者梯度处处为0.

- 参数稍微变一点, 只要预测类别没变, 精度就完全不变;

- 只有当任务变化刚好跨过决策边界时, 指标才会突然跳一下.

有关Loss, 我们在另一篇文章中讲解.

// - 它无法提供平滑的局部改进信号

== 任务求解与 Optimizer

=== 解析解

既然问题已经写成了:$ min_theta F(theta) $

那最自然的思路就是像高数和最优化那里一样, 直接找极值点, 即解$ nabla F(theta)=0 $

进一步地, 我们还可以分析Hessian矩阵, 讨论这个点是极小值, 极大值, 还是鞍点.

但是, 求解析解是很困难的, 基本上无法做到.

==== 维度

现代模型的参数 $theta$ 往往是很高维度的. 于是 $ nabla F(theta)=0 $

这个方程是一大团的高维方程, 几乎不能求解.

==== 非凸

即使我们有条件解这个方程, 且真的找到了某个驻点, 它也未必是我们想要的参数值. 可能是局部极小值, 或者是鞍点.

==== 数据量

看$ F(theta)=1/N sum_(i=1)^N cal(l)_i (theta) $本身是对*全体数据*的平均. 这意味着每计算一次 $F(theta)$, 都要*扫一遍全部数据*, 每计算一次 $nabla F(theta)$, 可能也都要扫一遍全部数据.

#thinking[经典优化里, 驻点分析往往是主线. 但是现在驻点本来就多, 结构复杂. 解方程这条路几乎行不通.]


=== 迭代解

我们通常做不到一步就把最优解写出来, 换句话说我们做不到把它看成一个*静态最优化问题*, 只能接受一种更为朴素的策略: 在当前参数点, 利用局部信息, 进行迭代, 变成一个*动态过程*. 即:$ theta_(t+1)=theta_t+Delta_t $

原问题就变成了一个新问题:

- $Delta_t$ 应该*往哪里走*.

- *走的距离是多远*.

- 需不需要*看历史记录*.

- 步长应该怎么变.

- 数据太大时, 每一步是看全体样本, 还是部分样本.


Optimizer 的目的是, 让优化目标 $F(theta)$ 以更快, 更稳, 更省内存的方式靠近目标. Optimizer 设计的就是这*每一步应该怎么走*.

= 朴素又奢侈的 Gradient Descent (GD)@nocedal2006numerical

站在 $theta_t$ 附近, 做一阶泰勒展开:$ F(theta_t +Delta)approx F(theta_t)+nabla F(theta_t)^T Delta $

如果我们限制这一步别走太远, 例如, $||Delta||<=eta$, 则让线性项下降最快的方向, 就是*负梯度方向*. 这个与梯度的几何意义是一致的.

最朴素的发明很容易被写出:

#definition[*Gradient Descent*
  $ theta_(t+1)=theta_t-eta nabla F(theta_t) $
]

```python
def step(self, full_grad_fn):
    grad = full_grad_fn()
    for p, g in zip(self.params, grad):
        p.add_(g, alpha=-self.lr)
```

它的优点非常直接, 每一步都朝着当前局部最陡下降方向走, 思想很朴素.

它的缺点也非常直接, 因为 $nabla F(theta_t)$ 是全量梯度, 即$ nabla F(theta_t)=1/N sum_(i=1)^N nabla cal(l)_i (theta_t) $

每走一步, 都得先看一遍*所有样本*! 一个epoch就迈了一步, 这也太奢侈了.

= 不太奢侈的 Stochastic Gradient Descent (SGD)@robbins1951stochastic

一个直觉的方法是, 全量梯度很贵, 那我们就不要精确算出来这个值了. 改用估计的. 给GD拆开看:

- *总体*: $N$ 个梯度 ${nabla cal(l)_1,nabla cal(l)_2,...,nabla cal(l)_N}$.

- *全量梯度*: 实际上就是这些梯度的平均值.

既然是估计, 我们可以试试局部样本代替整体. 也即, 从总体中随机抽一个样本, 用它来代替整体的平均值. 在实现时, 只需要计算被抽到样本的梯度即可.

设被抽到的梯度是 $i_t$, 那么估计量就是:$ g_t=nabla cal(l)_(i_t)(theta_t) $

它的期望是:$ EE[g_t]=sum_(i=1)^N P(i_t=i)dot nabla cal(l)_i (theta_t) $

如果我们随机抽, 也即 $P(i_t=i)=1/N$, 那么:$ EE[g_t]=1/N sum_(i=1)^N nabla cal(l)_i (theta_t)=nabla F(theta_t) $

恰好就是真实值. 这个估计是无偏估计. 重复迭代很多次, $g_t$ 可能偏高偏低, 但是平均来看, 它指向的方向和全量梯度是一致的, 即单次带来的噪声, 从全局来看, 均值为0.

#definition[*Stochastic Gradient Descent*

  $ theta_(t+1)=theta_t-eta g_t $]

```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    grad = batch_grad_fn(i)
    for p, g in zip(self.params, grad):
        p.add_(g, alpha=-self.lr)
```

它的优点很明显, 便宜.

但是它的缺点在前面被忽视了, 我们真的能忽视样本梯度估计带来的噪声吗?

单样本梯度 $g_t=nabla cal(l)_(i_t)(theta_t)$ 是无偏的, 但是它的方差很大:$ g_t=nabla F(theta_t)+epsilon_t,quad EE[epsilon_t]=0 $

噪声 $epsilon_t$ 让更新每一步都*随机翻转*. 也即, 行进方向的箭头 (梯度) *即刻改变*.

= 给SGD加惯性的Momentum@polyak1964some@sutskever2013importance

// == 噪声模型

// 设参数维度为 $d$, 单样本梯度可分解为真实信号加零均值的噪声:$ g_t=nabla F(theta_t)+epsilon_t,quad epsilon_t in RR^d $

// 满足假设: $EE[epsilon_t]=0$, $"Cov"(epsilon_t)=EE[epsilon_t epsilon_t^T]=sum in RR^(d times d)$ (半正定), 时间独立性: $EE[epsilon_t epsilon_s^T]=0 (t!=s)$.

// 上面知道, 单样本梯度方差是很大的:$ "Var"[g_t]=sigma^2 $

// 我们不妨假设

== 朴素想法

单样本梯度 $g_t$ 携带的噪声很大. 一个直接的思路是, 攒够 $k$ 轮再更新, 用样本平均代替单点估计. 即:$ overline(g)_t^((k))=1/k sum_(j=0)^(k-1)g_(t-j) $

这确实可以降低方差. 如果各轮噪声独立, 平均后的不确定性会被压缩.


但缺陷很明显:

- 浪费内存. 内存要存 $k$ 个历史梯度. 空间复杂度是 $O(k d)$, 其中 $d$ 是参数维度.

// - 如果攒够 $k$ 轮才更新一轮参数, 优化过程会出现"卡顿"; 如果在每轮都更新参数却只用梯度做估计, 逻辑混乱.

- 参数要么冻结 $k$ 轮, 要么一次性猛跳一步, 没有中间状态.

- 超参离散, $k$ 只能是正整数, 调参时无法精细控制平滑程度.


```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    g = batch_grad_fn(i) # 🤮

    self.history.append(g)
    if len(self.history) > self.k:
        self.history.pop(0)

    if len(self.history) == self.k:
        avg_g = sum(self.history) / self.k
        for p in self.params:
            p.add_(avg_g, alpha=-self.lr)
        self.history.clear()
```

// - 遇到平坦区该加速时, 被 $k$ 锁住了.

== 在线指数平均的Momentum方法

能不能不存 $k$ 个历史梯度, 只维护一个"浓缩了历史信息"的状态? Momentum 引入速度 $v_t$, 用递归把历史梯度折叠进去:
#definition[*Momentum*
  $
        v_(t+1) & =beta v_t+g_t \
    theta_(t+1) & =theta_t-eta v_(t+1)
  $
]
- 这里的 $v_t$ 是历史梯度的累积. 梯度不再直接推动位置, 而是改变速度.

- 每轮只存一个向量, 内存 $O(d)$. 每轮都更新参数, 没有冻结期.

- 速度作为状态递归传递, 实现了连续的平滑.

如果某个方向都在下降, 那这个方向的速度会不断累积, 更新越来越果断. 如果某个方向只是噪声来回翻转, 平均之后就会被抹平.


```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    g = batch_grad_fn(i)

    for p, grad in zip(self.params, g):
        v = self.state[p]['momentum_buffer']
        v.mul_(self.beta).add_(grad)
        p.add_(v, alpha=-self.lr)
```

== Momentum的平均色彩<sec:momentum_norm>

把递归展开, 假设 $t$ 足够大, 初始条件已衰减:$ v_(t+1)=g_t+beta g_(t-1)+beta^2 g_(t-2)+... $

简单归一化:$ tilde(g)_t^"mom"=(1-beta)v_(t+1)=sum_(j=0)^oo (1-beta)beta^j g_(t-j) $

== 同源的线性滤波

朴素 $k$-平均与Momentum都可以表示为:$ tilde(g)_t=sum_j w_j g_(t-j) $

其中, 朴素 $k$-平均的 $w_j$ 为 $1/k (j<<k),0 (j>=k)$; Momentum的 $w_j$ 为 $(1-beta)beta^j$.

朴素 $k$-平均的窗型是矩形窗, 硬截断, Momentum是指数窗, 软截断.

二者都是对历史随机梯度的线性加权平均, 差别仅在于记忆消退的方式. 朴素方法在 $k$ 步突然切断记忆; Momentum 让记忆指数衰减, 久远历史权重迅速缩小, 但每轮都即时响应新梯度.

== 降噪效果

=== 噪声模型

设参数维度为 $d$, 分解单样本梯度:$ g_t=nabla F(theta_t)+epsilon_t $
假设 $EE[epsilon_t]=0$, 且随时间独立. 关键对象是噪声的*协方差矩阵*:$ "Cov"(epsilon_t)=EE[epsilon_t epsilon_t^T]=inline(sum) in RR^(d times d) $

在这里, $inline(sum)$ 描述的是梯度噪声在参数空间中的联合波动结构:

- 对角元 $inline(sum_(p p))$: 第 $p$ 个参数维度上的噪声方差, 反映该参数估计的抖动幅度.

- 非对角元 $sum_(p q)$: 第 $p$ 个和第 $q$ 个参数维度上噪声的协方差. 反映它们是否倾向于同向或反向波动.

  例如, 神经网络中相邻层的权重可能因为同一条反向传播路径, 它们的噪声也是相关的.

- $sum$ 任意非零方向 $u in RR^d$ 上, 投影噪声 $u^T epsilon_t$ 的方差 $u^T sum u>=0$. 即 $sum$ 是正定的, 噪声不会完全坍缩到某个低维子空间.

=== 滤波后的协方差

对任意线性加权 $tilde(epsilon)=sum_j w_j epsilon_(t-j)$, 由于它随时间独立, 有$ EE[epsilon_(t-i)epsilon_(t-j)^T]=0,quad forall i!=j $

可得$ "Cov"(tilde(epsilon)) & =inline(sum)_(i,j)w_i w_j EE[epsilon_(t-i)epsilon_(t-j)^T] \
                      & =inline(sum)_j w_j^2inline(sum) \
                      & =(inline(sum)_j w_j^2)inline(sum) $

滤波后的协方差矩阵是原始矩阵 $sum$ 的严格标量倍数 $c dot sum$, 等比例收缩, 形状不变, 整体缩小.

整个参数空间中的估计不确定性被均匀压制.

==== 朴素 $k$-平均

$ c=sum_(j=0)^(k-1)(1/k)^2=1/k \ "Cov"(overline(g)_t^((k)))=1/k inline(sum) $

==== Momentum 归一化后

$
  c=sum_(j=0)^oo ((1-beta)beta^j)^2=((1-beta)^2)/(1-beta^2)=(1-beta)/(1+beta)\ "Cov"(tilde(g)_t^"mom")=(1-beta)/(1+beta)inline(sum)
$

==== 等价关系

如果我们令压缩系数相等, 即 $ 1/k=(1-beta)/(1+beta)=>k=(1+beta)/(1-beta) $

例如, $beta=0.9$ 对应约 $k=19$ 的朴素平均.

Momentum用 $O(1)$ 存储和每轮更新, 实现了等效的方差压缩. 因此它比朴素方法更受欢迎.

= 优化器的能量定律

这是一节插叙的内容.

我们可以将优化过程建模为一个物理耗散动力学系统:

- 势能 $U(theta)$: 损失函数盈余 $F(theta)-F(theta^*)$.

- 动能 $K(v)$: 粒子运动惯性 $(eta^2)/(2(1-beta))||v||^2$.

- 总能量 $cal(E)=U+K$.

优化器的核心任务, 就是在不至于震荡失控的前提下, 以*最快速度*消耗掉总能量 $cal(E)$, 让粒子静止在势能最低点.

在一次迭代的过程中, 系统可以经过三种能量转换:

+ 势能 $->$ 动能: 粒子顺着斜坡下滑, 重力 (负梯度) 做功, 动能增加.

+ 动能 $->$ 势能: 粒子凭惯性冲过谷底, 爬上对面的斜坡, 动能转换为势能.

+ 摩擦耗散: 速度衰减因子 $beta,beta<1$. 每次迭代, 系统以 $(1-beta)$ 的比例将动能转化为热能散失.




// == 优化作为耗散动力学

// 把损失曲面 $F(theta)$ 视为*势能场*, 参数 $theta$ 是场中*粒子*的坐标. 优化的目标就是把粒子驱赶到*势能最低点*.

// 前面我们介绍了梯度下降法, $theta_(t+1)=theta_t-eta nabla F(theta_t)$ 相当于粒子在保守力场中沿最陡下降方向移动.

// 但是纯GD没有记忆, 每步更新前的粒子速度归零, 势能的减少量直接耗散到外界. 这更像准静态的蠕动, 缺乏运动学结构.

// 为了赋予优化过程动力学特征, 需要引入动能.

// == 势能, 动能与总能量

// 定义势能盈余为当前点与最优值的差距:$ U_t=F(theta_t)-F(theta^*)>=0 $

// Momentum 引入速度 $v_t$, 粒子开始具有惯性. 速度是历史梯度的累积. 动能定义为:$ K_t=(eta)/(2(1-beta))||v_t||^2 $

// 系数 $eta/(2(1-beta))$ 的选取, 使得动能与势能的变化在更新中形成对偶. 总能量定义为:$ epsilon_t & =U_t+K_t \
//           & =underbrace(F(theta_t)-F(theta^*), "势能盈余")+underbrace(n/(2(1-beta))||v_t||^2, "动能") $

// 在物理保守系统中, 总能量守恒. 在优化过程中, 总能量必须单调递减, 否则粒子永远无法静止在谷底. 这意味着优化器本质上是一个耗散系统, 需要内置摩擦机制将能量不可逆地散失.

// 在Momentum的一次迭代中, 发生三次能量流动:

// *势能向动能转换*. 梯度 $g_t$ 沿下降方向注入系统, 速度增加, 动能上升. 对应下长坡时的加速.

// *动能向势能回流*. 速度推着粒子越过谷底, 粒子爬上另一侧势能坡, 动能减少, 势能回升, 对应过冲.

// *摩擦耗散*. $beta<1$ 在每轮速度更新中施加指数衰减, 相当于粒子在粘滞介质中运动. 部分动能被环境吸收, 以热的形式散失.

// 因为摩擦项持续存在, 总能量 $epsilon_t$ 呈递减趋势. 震荡的振幅随时间指数衰减, 最终粒子静止在势能井底.

// == 能量损耗与收敛

// Momentum是一个欠阻尼谐振子:

// - 损失曲面的Hessian提供恢复力, 指向谷底.

// - 速度 $v_t$ 提供惯性.

// - $beta$ 提供阻尼.

// 三者构成二阶动力学系统. 当阻尼系数 $beta$ 较大 (接近1), 系统处于欠阻尼状态: 粒子围绕谷底振荡数次, 每次振幅按 $beta^t$ 衰减. 当 $beta$ 较小, 系统过阻尼, 直接滑向谷底, 无震荡.

// 收敛的必然性来自 $beta<1$. 一旦外部梯度供给减弱 (靠近平衡点), 摩擦会自发消耗残余动能, 不存在永恒震荡.


// Momentum的能量管理存在一个结构性盲区: 它只根据当前位置的梯度来调节速度. 粒子凭惯性高速滑行时, 它读取的是脚下的坡度, 而非前方即将撞上的破壁.

// 这意味着动能的调节是滞后的. 梯度 $g_t$ 在位置 $theta_t$ 计算, 但速度 $v_(t+1)$ 推动的是粒子前往 $theta_(t+1)$. 当曲面几何突变 (例如从长下坡急转入谷底), 当前位置的梯度信号来不及在速度中形成足够的反向制动.

// 多余的动能只能等到冲过头之后, 在对面的上坡上才会被消耗.

// Momentum缺乏预见性的能量控制.

= 软着陆的Nesterov Accelerated Gradient (NAG)@nesterov1983method

Momentum其实来自于现实世界, 所以现实世界的问题也被学来了. Momentum的能量管理是盲目的. 它在 $theta_t$ 处计算梯度, 却用累积的动能把粒子推向 $theta_(t+1)$.

$
      v_(t+1) & =beta v_t+g_t \
  theta_(t+1) & =theta_t-eta v_(t+1)
$

当粒子以极高速度冲向山谷底部时, 由于惯性 $beta v_t$ 的存在, 它会盲目地冲上对面的斜坡, 导致剧烈震荡.

那就引入刹车机制, 检测到*前方*是"上坡", 主动刹车.

在这里, 前方就是当前运动方向 $-beta eta v_t$ 往前看. 我们希望惯性系数 $beta$ 受到地形曲率调制. 动量更新的形式:$ v_(t+1)=underbrace(beta(I-eta H(theta_t)), "受曲率调制的惯性")v_t+g_t $

其实 $H(theta_t)$ 是当前点 $theta_t$ 的Hessian矩阵, 代表局部曲率.


- 当处于平缓的坡道时, 曲率 $H approx 0$, 算子接近 $beta$, 粒子全速前进, 保留最大惯性.

- 当高速冲向陡峭的谷底, 即将迎来上坡时: 曲率 $H>0$ (正定). 此时, $(I-eta H)$ 算子会使得系数明显小于 $beta$.

  二阶导为正, 检测到前方有上坡 (二阶导为正), 算法立刻降低 $beta$, 强行消减动能.


这个设计在物理上很完美, 但是计算Hessian矩阵的开销是无法接受的.

== Look-ahead

对"前方某个预测点"的梯度进行一阶泰勒展开. 在当前位置 $theta_t$, 沿着动量方向预测一步, 走到 $theta_(t+1)=theta_t-beta eta v_t$. 这一点的梯度:$ nabla F(theta_t-beta eta v_t)approx nabla F(theta_t)-redit(beta eta H(theta_t)v_t) $

这里其实就是我们想要的刹车项. 把它代回到我们期望的"刹车动量"公式中:

$
  v_(t+1) & approx beta v_t-beta eta H(theta_t)v_t+nabla F(theta_t) \
          & =beta v_t+(nabla F(theta_t)-beta eta H(theta_t)v_t) \
          & approx beta v_t+nabla F(theta_t-beta eta v_t)
$

我们不需要计算Hessian矩阵, 只需要在预测点计算一次梯度即可.

$
  theta_t^"look" & =theta_t-beta eta v_t \
      g_t^"look" & =nabla F(theta_t^"look") \
         v_(t+1) & =beta v_t+g_t^"look" \
     theta_(t+1) & =theta_t -eta v_(t+1)
$

这在理论上非常完美, 但Look-ahead极大破坏了反向传播流水线的连贯性.


```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    theta_look = [p - self.beta * self.lr * v for p, v in zip(self.params, self.v)]
    grad = batch_grad_fn(i, theta_look) # 🤮
    for p, g, v in zip(self.params, grad, self.v):
        v.mul_(self.beta).add_(g)
        p.add_(v, alpha=-self.lr)
```

== 狸猫换太子

在PyTorch里, 梯度计算与内存中的参数张量强绑定. `loss.backward()` 只会对 `requires_grad=True` 的叶子节点*累积梯度*, 这些叶子节点就是 `nn.Parameter` 在内存中的当前值.

原始 NAG 要求在点 $theta_t-beta eta v_t$ 处计算梯度. 如果想要保存当前参数, 要么临时篡改内存, 改完再改回来; 要么额外构造临时张量做前向传播, 让梯度回传路径变得别扭.

如果内存里存的*就是那个lookahead点*, PyTorch的 `backward()` 自动就在正确的位置上算梯度了, 不需要任何临时构造, 事后还原即可. 这就是狸猫换太子的手法.

如果我们决定内存里只存 `lookahead` 点, 那么整套更新规则需要改写为只围绕这个内存点运转. 下面我们展开写:


设内存中实际存储的参数为 $y_t$, 它就是我们本来打算用来算梯度的 `lookahead` 点, 我们期望, PyTorch能对它进行自动梯度. 则令 $ y_t & =theta_t^"look"=theta_t-beta eta v_t \
    & =>g_t^"look"=nabla F(y_t) $


由此我们把 $theta_t$ 从迭代中消去. 下面我们把涉及到 $theta_t$ 的项, 全部由 $y_t$ 表示.

由约定反解:$     theta_t & =y_t+beta eta v_t \
theta_(t+1) & =theta_t-eta v_(t+1) \
            & =(y_t+beta eta v_t)-eta v_(t+1) $

而 $y_(t+1)$ 按定义应该满足:$ y_(t+1) & =theta_(t+1)-beta eta v_(t+1) \
        & =y_t+beta eta v_t-eta v_(t+1)-beta eta v_(t+1) \
        & =y_t+eta(beta v_t-v_(t+1)-beta v_(t+1)) $

将 $v_(t+1)=beta v_t+g_t^"look"$ 代入:$ y_(t+1) & =y_t+eta[beta v_t-beta v_t-g_t^"look"-beta v_(t+1)] \
        & =y_t+eta[-g_t^"look"-beta v_(t+1)] \
        & =y_t-eta(g_t^"look"+beta v_(t+1)) $

现在整套迭代只依赖 $(y_t,v_t)$:$ redit(g_t^"look"&=nabla F(y_t)\ v_(t+1)&=beta v_t+g_t^"look"\ y_(t+1)&=y_t-eta (g_t^"look"+beta v_(t+1))) $

在代码里, 我们把 $y_t$ 重命名为 `self.params`.

#definition[*Nesterov Accelerated Gradient (NAG)*
  $
        v_(t+1) & =beta v_t+g_t \
    theta_(t+1) & =theta_t-eta(g_t+beta v_(t+1))
  $

  在训练结束后, 还原真实参数, 我们还需要做一次补偿:$ theta_T^"true"=theta_T+beta eta v_T $
]

```python
def __init__(self, params, lr=0.01, momentum=0.9):
    self.params = list(params)
    self.lr = lr
    self.momentum = momentum
    self.state = {}
    for p in self.params:
        self.state[p] = {'momentum_buffer': torch.zeros_like(p)}

def step(self, batch_grad_fn):
    grad = batch_grad_fn()

    for p, g in zip(self.params, grad):
        v = self.state[p]['momentum_buffer']
        v.mul_(self.momentum).add_(g)
        p.add_(g + self.momentum * v, alpha=-self.lr)

def finalize(self):
    for p in self.params:
        v = self.state[p]['momentum_buffer']
        p.add_(v, alpha=self.momentum * self.lr)
```

= 从时间管理到空间管理

这是一节插叙的内容.

前面我们讨论了SGD引入了空间上的单点随机性 (带来噪声), 而 Momentum / NAG 引入了时间上的滤波器 (利用历史减少方差, 预测未来).

它们实际上都是假定在*所有参数地位相同*这个前提上的. 对所有参数一视同仁, 使用的都是全局学习率 $eta$.

== 弊端

考虑这个二维二次函数:$ f(theta)=1/2 (100theta_1^2+theta_2^2),quad theta^((0))=(1,1) $

它的梯度为:$ nabla f(theta)=mat(100theta_1; theta_2) $

Hessian矩阵为: $"diag"(100,1)$. 这个函数的等高线是一组*极度扁平*的椭圆, 在 $theta_1$ 方向*非常窄*, 在 $theta_2$ 方向非常宽.

我们以 SGD 为例, 它的更新为:$ theta_(t+1)=theta_t-eta nabla f(theta_t)\ theta_(1,t+1)=(1-100eta)theta_(1,t),quad theta_(2,t+1)=(1-eta)theta_(2,t) $

为了保证 $theta_1$ 不发散, 必须满足 $abs(1-100 eta)<1$. 我们取 $eta=0.019$, 刚好踩在稳定边界上. 下面进行迭代:


#table(
  columns: (auto, 1fr, 1fr, 1fr),
  column-gutter: 10pt,
  stroke: none,
  align: center,
  table.hline(),
  table.header([*_Step_*], [*$theta_1$*], [*$theta_2$*], [*$f(theta)$*]),
  table.hline(stroke: 0.5pt),
  [0],
  [$+1.000$],
  [$+1.000$],
  [$50.500$],
  [1],
  [$-0.900$],
  [$+0.981$],
  [$40.981$],
  [5],
  [$+0.656$],
  [$+0.908$],
  [$21.952$],
  [10],
  [$-0.269$],
  [$+0.824$],
  [$14.023$],
  [20],
  [$+0.122$],
  [$+0.684$],
  [$9.849$],
  [50],
  [$-0.005$],
  [$+0.377$],
  [$5.146$],
  [100],
  [$approx 0$],
  [$+0.142$],
  [$2.512$],
  [200],
  [$0$],
  [$+0.020$],
  [$2.000$],
  table.hline(),
)

$theta_1$ 在震荡中快速归零. 每步振幅衰减 $10%$, 50步就能收敛到0. 虽然它确实在靠近最优点, 但是路径确是剧烈震荡的.

$theta_2$ 在单调缓慢爬行. 每步只衰减 $1.9%$, 200步后还在0.02附近, 不震荡, 但是也几乎不动.

- 为了 $theta_1$ 不爆炸, $eta$ 必须小于0.02. 但是这个 $eta$ 对于 $theta_2$ 太小了, 它的梯度只有1. 每步只走0.019, 收敛速度很慢.


因此, 整体的收敛速度被最慢的坐标决定, 稳定性被最敏感的坐标决定. 每个坐标的历史行为是不一样的. $theta_1$ 长期收到大幅梯度, $theta_2$ 长期只有微弱信号.

显然, 方法就是自适应步长, 让它随着参数自动调节. 现在问题转换为, 全局学习率 $eta$ 是一个总预算, 如何把它分配给各个坐标?

== 稳定性条件

对于二次函数, SGD在每个坐标上的更新可以表示为:$ theta_(j,t+1) & =theta_(j,t)-eta g_(j,t) \
              & =theta_(j,t)-eta H_(j j)theta_(j,t) \
              & =(1-eta H_(j j))theta_(j,t) $

这个坐标不得发散, 因此必须满足:$ abs(1-eta H_(j j))<1 $

因此, 这里告诉我们每个坐标 $j$ 都有一个自己的安全学习率上限:$ eta<2/(H_(j j)) $

$H_(j j)$ 其实就是这个方向的二阶导数 (曲率). 曲率越大, 说明该坐标能承受的 $eta$ 越小.

在我们的例子中, $theta_1$ 的 $H_11=100$, 因此安全上限 $eta<0.02$, $theta_2$ 的 $H_22=1$, 安全上限 $eta<2$.

全局 $eta=0.019$ 刚好满足 $theta_1$ 的约束, 但是对于 $eta_2$ 来说, 只用了它容量的 $1%$.

== 一个理想实验

高僧预测了 $H_11=100$, $H_22=1$ (其实是假设我们已知Hessian矩阵).

考虑每个坐标独立的更新:$ theta_j^((1))=theta_j^((0))-eta_j g_j^((0)) $

已知 $g_j=H_(j j)theta_j$, 所以:$ theta_j^((1))=theta_j^((0))-eta_j H_(j j)theta_j^((0))=(1-eta_j H_(j j))theta_j^((0)) $

由于 $1-eta_j H_(j j)$ 就是该坐标下每步的衰减率. 在SGD中, 由于全局 $eta$ 相同, 两个坐标的衰减率完全不同. $theta_1:1-0.019times 100=-0.9$, 每步衰减 $10%$, $theta_2:1-0.019times 1=0.981$, 每步只衰减 $1.9%$, 正好解释了前面的符号翻转和缓慢爬行.

如果我们想让两个坐标同步收敛 (都衰减到原来的 $50%$), 就需要让 $1-eta_j H_(j j)$ 对两个坐标取相同的值. 设目标衰减率为 $c$:$ 1-eta_j H_(j j)=1-c $

取 $c=0.5$, 即每步走一半:$ eta_1=0.5/100=0.005,quad eta_2=0.5/1=0.5. $


更新:

$ theta_1^((1))=0.5,quad theta_2^((1))=0.5 $

两个坐标同步衰减 $50%$, 同步向最优值靠近. $theta_1$ 不再震荡, $theta_2$ 也不再拖延.

= 参数可自己定步长的AdaGrad@duchi2011adaptive

然而在训练中没有高僧. 训练中我们不知道 $H_(j j)$. 直接计算二阶导数需要 $O(d^2)$ 存储和 $O(d^3)$ 求逆矩阵, 这无法接受. 因此我们需要一个估计值.


== 我们到底在要什么

从理想实验来看, $H_(j j)$ 本身的尺度, 最终还要受限于 $eta$ 这个超参数指定的值. 因此我们并非想要 $H_(j j)$ 的绝对值, 而是各个对角上它们的相对大小, 以便能按照其条件分配 $eta$.

$H_(j j)$ 本身的尺度, 最终还要受限于 $eta$ 这个超参数指定的值. 我们更看重的还是对角元素的相对大小关系.



== 朴素的估计方法

=== 初步的估计

考虑一般光滑损失函数 $f(theta)$, 在极小值点 $theta^*$ 附近做泰勒展开. 令 $ tilde(theta)=theta-theta^* $
为偏离最优值的位移, 对梯度 $g(theta)=nabla f(theta)$ 在 $theta^*$ 处展开:$ g(theta)=g(theta^*)+H(theta^*)tilde(theta)+O(||tilde(theta)||^2) $

由于 $theta^*$ 是极小值点, $g(theta^*)=0$. 忽略高阶项, 得到局部线性近似:$ g(theta)approx H(theta^*) tilde(theta) $

其中, $H(theta^*)$ 是Hessian矩阵. 写成坐标的形式:$ g_i approx sum_k H_(j k)tilde(theta)_k $

对于病态优化问题中, Hessian不同坐标的耦合较弱, 我们近似地忽略非对角项:$ g_j approx H_(j j)tilde(theta)_j => H_(j j)approx g_j/tilde(theta)_j $

这个理论上的关系很美好, 知道了位移, 就能算出曲率. 但是训练中我们不知道 $theta^*$, 自然也不知道 $tilde(theta)_j$. 我们无法使用这个公式来估计 $H_(j j)$.

=== 用 $g_j$ 一阶代理

既然 $tilde(theta)_j$ 未知, 我们退一步看 $g_j$ 能不能代理 $H_(j j)$. 但单步梯度必然携带噪声.

假设参数在最优值附近对称分布, $tilde(theta)_j~cal(N)(0,sigma^2)$. 同时引入噪声 $epsilon.alt~cal(N)(0,sigma_epsilon.alt^2)$, 且 $epsilon.alt_j$ 与 $tilde(theta)_j$ 独立. 在局部近似下:$ g_j=H_(j j)tilde(theta_j)+epsilon.alt_j $

由于正态分布的线性组合性质, $g_j$ 仍然服从正态分布. 即 $g_j~cal(N)(0,sigma_(g,j)^2)$, 其中总方差为:$ sigma_(g,j)^2=H_(j j)^2 sigma^2+sigma_(epsilon.alt)^2 $

取期望:$ EE[g_j]=H_(j j)EE[tilde(theta)_j]+EE[epsilon.alt_j]=0 $

显然, 期望直接归零了, 没办法反映 $abs(H_(j j))$ 的大小.

那如果我们看绝对值 $abs(g_j)$ 呢?

#thinking[
  对于正态分布 $X~cal(N)(0,sigma^2)$, 其绝对值的期望是 $ EE[abs(X)]=sigma sqrt(2/pi) $
]

有$ EE[abs(g_j)]=sigma_(g,j)sqrt(2/pi)=sqrt(H_(j j)^2 sigma^2+sigma_(epsilon.alt)^2)sqrt(2/pi) $


在各坐标共享同一 $sigma^2$ 与 $sigma_epsilon.alt^2$ 的意义下, $abs(g_j)$ 携带了 $abs(H_(j j))$ 的信息. 它的方向是对的.

// 若 $tilde(theta)_j~cal(N)(0,sigma^2)$, 则 $EE[abs(tilde(theta)_j)]=sigma sqrt(2/pi)$. 于是 $ EE[abs(g_j)]approx abs(H_(j j))sigma sqrt(2/pi) $

// 在各坐标共享同一 $sigma$ 的意义下, $abs(g_j)$ 是 $abs(H_(j j))$ 的*比例无偏估计*. 方向是对的.

然而单步方差很大. 由于 $EE[g_j^2]=sigma_(g,j)^2$, 得 $abs(g_j)$ 的方差为:$ "Var"(abs(g_j)) & =EE[g_j^2]-(EE[abs(g_j)])^2 \
                & =sigma_(g,j)^2-sigma_(g,j)^2 2/pi \
                & = sigma_(g,j)^2 (1-2/pi) $

相对标准差:$ sqrt("Var"(abs(g_j)))/(EE[abs(g_j)])=(sqrt(1-2/pi))/(sqrt(2/pi))=sqrt((pi-2)/2)approx 75.5% $

单步估计的相对误差是不可接受的.

== Momentum的思想应用 (1)

我们自然联想到Momentum的思想.

=== 一阶

这个在前面已经被我们毙了, 但是我们还是观察观察它的波动情况.

不止看这一步, 还看历史上的所有观测:$ S_(t,j)=sum_(tau=0)^t g_(tau,j) $

假设各步独立, 则:$    EE[S_(t,j)] & =(t+1)EE[g_j]=0 \
"Var"(S_(t,j)) & =(t+1)"Var"(g_j) \
               & =(t+1)H_(j j)^2 sigma^2 $


历史累加后期望仍然是0, 无法估计 $abs(H_(j j))$; 而绝对波动反而以 $sqrt(t+1)$ 增长.

正负梯度在历史长河中相互抵消, 能量无法累积.

=== 绝对值

$
  A_(t,j)=sum_(tau=0)^t abs(g_(tau,j))
$

期望:$ EE[A_(t,j)] & =(t+1)sigma_(g,j)sqrt(2/pi) \
            & =(t+1)sqrt(H_(j j)^2 sigma^2+sigma_epsilon.alt^2)sqrt(2/pi) $

这条路走不通, 因为绝对值函数有一个致命的代数缺陷. 它把信号和噪声嵌在同一个根号里, 无法解耦. $H_(j j)^2 sigma^2$ 与 $sigma_epsilon.alt^2$ 被捆绑在一起.

// 研究 $ H_(j j)^2 sigma^2+sigma_epsilon.alt^2 $

当 $H_(j j)=0$ 时, 被噪声强行抬高$ EE[A_(t,j)]=(t+1)sigma_epsilon.alt sqrt(2/pi)>0 $

当 $H_(j j)$ 很大时, $ EE[A_(t,j)]approx (t+1)abs(H_(j j))sigma sqrt(2/pi) $

这意味小曲率坐标被噪声垫高, 大曲率坐标被噪声稀释, 比例关系永远不是 $abs(H_(j j))$ 的线性函数.

== 用当前梯度估计Hessian矩阵对角的相对大小

// 我们被困在了一次关系里: $g_j approx H_(j j)tilde(theta)_j$ 中, $tilde(theta)_j$ 未知, 解不出 $H_(j j)$.

// 更麻烦的是, 即使 $tilde(theta)_j$ 已知, 单步 $g_j$ 是有正有负的, 从整体看会出现 $g_j$ 累加导致正负抵消.


// AdaGrad的突破口就在于, 它不再去估计 $H_(j j)$ 本身, 而是估计 $H_(j j)$ 的相对大小.

=== 合理性

处理正负抵消的一个好方法是两边取平方, 即:$ g_j^2 approx H_(j j)^2 tilde(theta)_j^2 $

它也是正态分布. 我们下面研究它的期望和方差.

$
  EE[g_j^2] & =H_(j j)^2 EE[tilde(theta)_j^2]+EE[epsilon.alt_j^2]+2H_(j j)EE[tilde(theta)_j epsilon.alt_j] \
            & stretch(=)^("独立性")H_(j j)^2 sigma^2+sigma_epsilon.alt^2
$

这样, $H_(j j)^2 sigma^2$ 与噪声 $sigma_(epsilon.alt)^2$ 是通过加法线性分离的. 即使噪声不小, 它也是公共偏移, 不影响 $H_(j j)^2$ 的比例关系. 只要它在各坐标间是公共因子, 比较 $EE[g_j^2]$ 的相对大小就能反馈 $H_(j j)^2$ 的相对大小.

在 $sigma_epsilon.alt^2$ 为各坐标公共因子的意义下, $g_j^2$ 是 $H_(j j)^2$ 的比例无偏估计. 能用梯度能量取估计曲率能量的相对大小.

=== 不足

$
  "Var"(g_j^2)=EE[g_j^4]-(EE[g_j^2])^2
$

其中 $g_i~cal(N)(0,sigma_(g,j)^2)$, 其中 $sigma_(g,j)^2=H_(j j)^2sigma^2+sigma_epsilon.alt^2$.

#thinking[
  对于正态分布 $X~cal(N)(0,sigma^2)$, 有$ EE[X^4]=3sigma^4 $
]

因此$    EE[g_i^4] & =3(sigma_(g,j)^2)^2=3(H_(j j)^2 sigma^2+sigma_epsilon.alt^2)^2 \
"Var"(g_j^2) & =3(sigma_(i,j)^2)^2-(sigma_(g,j)^2)^2=2(sigma_(g,j)^2)^2 $

相对标准差:$ sqrt("Var"(g_j^2))/(EE[g_j^2])=(sqrt(2)sigma_(g,j)^2)/(sigma_(g,j)^2)=sqrt(2)approx 141% $

单步估计的相对误差超过了100%, 完全不可接受. 一步观测到的梯度, 可能连真实曲率的影子都抓不到.

总结一下, 我们现在找到了 $H_(j j)$ 的一个较好的代替, 用二阶的 $g_j$ 来近似 $H_(j j)^2$, 虽然它本身的方差很大, 但是下一步我们对它算Momentum时, $H_(j j)^2 sigma^2$ 与噪声 $sigma_epsilon.alt^2$ 是线性分离的.

== 用历史累加来稳定估计的AdaGrad

那就把Momentum的思想代进去吧:$ G_(t,j)=sum_(tau=0)^t g_(tau,j)^2 $

在局部近似下, 每一步都满足 $g_(tau,j)approx H_(j j)tilde(theta)_(tau,j)+epsilon.alt(tau, j)$, 所以:$ G_(t,j)&=sum_(tau=0)^t g_(tau,j)^2 \ &= H_(j j)^2 sum_(tau=0)^t tilde(theta)^2_(tau,j)+sum_(tau=0)^t epsilon.alt_(tau,j)^2+2H_(j j) sum_(tau=0)^t tilde(theta)_(tau,j) epsilon.alt_(tau,j) $

取期望, 交叉项由独立性归零:$ EE[G_(t,j)] & =H_(j j)^2 sum_(tau=0)^t EE[tilde(theta)_(tau,j)^2]+sum_(tau=0)^t EE[epsilon.alt_(tau,j)^2] \
            & = (t+1)(H_(j j)^2 sigma^2+sigma_epsilon.alt^2) $

现在看两个坐标 $j$ 和 $k$ 的比例. 如果两个坐标的参数轨迹在同一个阶段具有相近的量级, 即 $sum tilde(theta)_(tau,j)^2$ 与 $sum tilde(theta)_(tau,k)^2$ 处于同一个数量级, 且噪声背景 $sum epsilon.alt^2_(tau,j)$ 与 $sum epsilon_(tau,k)^2$ 也是各坐标共享的公共因子, 那么:$ (G_(t,j))/(G_(t,k))approx EE[G_(t,j)]/EE[G_(t,k)]=(H_(j j)^2 sigma^2+sigma_epsilon.alt^2)/(H_(k k)^2 sigma^2+sigma_epsilon.alt^2) $

当信号项远大于噪声背景时, 比例趋近 $H_(j j)^2/H_(k k)^2$. 累加操作起到了平滑噪声和稳定估计的作用.

再看方差. 由独立同分布的方差可加性:

$
  "Var"(G_(t,j)) & =(t+1)"Var"(g_j^2) \
                 & =2(t+1)(H_(j j)^2 sigma^2+sigma_epsilon.alt^2)^2
$

相对标准差: $ sqrt("Var"(G_(t,j)))/(EE[G_(t,j)])&=(sqrt(2(t+1))(H_(j j)^2 sigma^2+sigma_epsilon.alt^2))/((t+1)(H_(j j)^2 sigma^2+epsilon.alt^2))\ &=(sqrt(2))/(sqrt(t+1)) $

历史累积以 $O(1/sqrt(t))$ 的速率压制方差, 使得 $G_(t,j)$ 成为 $H_(j j)^2$ 的可靠代理.


// 现在看两个坐标 $j$ 和 $k$ 的比例:$ (G_(t,j))/(G_(t,k))approx (H_(j j)^2 sum_(tau=0)^t tilde(theta)_(tau,j)^2)/(H_(k k)^2 sum_(tau=0)^t tilde(theta)_(tau,k)^2) $

// 如果两个坐标的参数轨迹在同一阶段具有相近的量级, 即 $sum tilde(theta)^2_(tau,j)$ 和 $sum tilde(theta)^2_(tau,k)$ 处于同一数量级, 那么求和项起到近似的公共归一化的作用, 比例就主要由曲率决定:$ (G_(t,j))/(G_(t,k))approx (H_(j j)^2)/(H_(k k)^2) $



// 累加操作起到了平滑噪声和稳定估计的作用. 单步可能碰巧不准, 但历史上百步, 上千步的能量累积, 会让曲率大的坐标自然脱颖而出.

那么既然 $G_(t,j) prop H_(j j)^2$, 那么$ sqrt(G_(t,j))prop abs(H_(j j)) $

让学习率与它成反比即可:
$ eta_(t,j)^"eff" = eta / sqrt(G_(t,j) + epsilon) prop 1/(abs(H_(j j))) $


#definition[*AdaGrad*

  $ theta_(t+1) = theta_t - eta / sqrt(G_t + epsilon) dot.circle g_t $
]

```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    g = batch_grad_fn(i)

    for p, grad in zip(self.params, g):
        G = self.state[p]['grad_sq_sum']
        G.add_(grad * grad)
        eff_lr = self.lr / (G.sqrt() + self.eps)
        p.add_(grad, alpha=-eff_lr)
```

回到例子, 第一步:

#table(
  columns: (auto, auto, auto, auto, auto, 1fr),
  column-gutter: 10pt,
  stroke: none,
  align: center,
  table.hline(),
  table.header(
    [*坐标*], [*初始值*], [*梯度 \ $g_0$*], [*历史能量\  $G_(0,j)$*#v(5pt)], [*有效学习率\  $eta^"eff"$*], [*更新后*]
  ),
  table.hline(stroke: 0.5pt),
  [$theta_1$],
  [$1.0$],
  [$100$],
  [$10000$],
  [$0.01$],
  [$0$],
  [$theta_2$],
  [$1.0$],
  [$1$],
  [$1$],
  [$1.0$],
  [$0$],
  table.hline(),
)

一步就可以到达最优值. AdaGrad用一阶历史信息自动完成了对二阶曲率的代理估计, 然后让学习率与曲率成反比.

= 懂得遗忘的RMSprop@tieleman2012rmsprop

说句题外话, 看到这里, 已经把最难的地方看过去了. 前面没理解的可以回头消化消化, 如有错误欢迎指正 :)

AdaGrad用历史能量 $ G_(t,j)=sum_(tau=0)^t g_(tau,j)^2 $衡量坐标敏感度, 这个思路是有效的.

但是它假设了*所有历史梯度对当前参数状态具有同等代表性*. 时间越久远的梯度, 结果却被以1的权重塞进了分母. 也即, 这导致了 $G_(t,j)$ 单调不减.

训练后期分母膨胀, 有效步长被压缩到接近于0, 参数直接被原地冻住了.

算数赋予每个历史永久席位, 却没有遗忘机制. Momentum给我们了一个现成的工具, 回顾Momentum的速度累积:$ v_t=beta v_(t-1)+(1-beta)g_t $

它用指数衰减实现了一种柔性遗忘: 近期梯度权重高, 远期梯度以 $beta$ 的幂次快速淡出. 把这种思想搬到二阶矩的积累上, 历史能量也应该以指数形式衰减, 而非永久累加:$ v_(t,j)=gamma v_(t-1,j)+(1-gamma)g_(t,j)^2 $

其中, $gamma in [0,1)$ 是衰减率, 通常是0.9. 展开来看, $ v_(t,j)=(1-gamma)sum_(tau=0)^t gamma^(t-tau)g_(tau,j)^2 $

远期梯度 $g_(tau,j)^2$ 的权重按 $gamma^(t-tau)$ 指数衰减, 这样, $v_(t,j)$ 始终有界.

#definition[*RMSprop*
  $
          v_(t,j) & =gamma v_(t-1,j)+(1-gamma)g_(t,j)^2 \
    theta_(t+1,j) & =theta_(t,j)-eta/(sqrt(v_(t,j)+epsilon.alt))g_(t,j)
  $
]
```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    g = batch_grad_fn(i)

    for p, grad in zip(self.params, g):
        v = self.state[p]['second_moment']
        v.mul_(self.gamma).add_(grad * grad, alpha=1 - self.gamma)
        eff_lr = self.lr / (v.sqrt() + self.eps)
        p.add_(grad, alpha=-eff_lr)
```

= 集大成者的Adam@kingma2014adam

// Momentum从时间维度上减少了噪声, RMSprop感知到了空间维度上的曲率, 对症下药. 把两个已经打磨好的组件拼在一起, 是再自然不过的发明了.

// 再回顾一下这两个方法的核心:

== 拼接灵感

*Momentum*:
$
      v_(t+1) & =beta v_t+g_t \
  theta_(t+1) & =theta_t-eta redit(v_(t+1))
$


*RMSprop*:
$
        v_(t,j) & =gamma v_(t-1,j)+(1-gamma)g_(t,j)^2 \
  theta_(t+1,j) & =theta_(t,j)-eta/(redit(sqrt(v_(t,j)+epsilon.alt)))g_(t,j)
$

// #thinking[
//   虽然两个式子都用了符号 $v$, 但是干的是完全不同的活.

//   Momentum的 $v$ 是历史梯度的加权平均. 它解决的是时间维度上的噪声, 单步梯度 $g_t$ 噪声过大, 于是将前几轮的梯度折进一个状态里, 输出一个更稳定的方向共识.

//   RMSprop的 $v$ 是历史梯度平方的加权平均. 它解决的是空间维度上的曲率差异, 让每个坐标对学习率 $eta$ 自带一个缩放因子.
// ]
//
两个状态都叫 $v$, 拼装时容易混淆. 先把 Momentum 改叫 $m$, RMSprop保留 $v$, 统一时间线, 均只接收 $v_(t-1)$, 统一不展示分量形式.

#thinking[注意, Momentum的$v_(t+1)=>v_t,v_t=>v_(t-1)$ 这里不是统一减1, 而是表示前后顺序, 因此 $g_t$ 不应该换.

  在下面Nadam里的替换也有这个思想, 注意辨别.]

$
  m_t & =beta_1 m_(t-1)+g_t \
  v_t & =beta_2 v_(t-1)+(1-beta_2)g_t^2
$


拼接是很自然的.

$
  theta_(t+1)=theta_t-(eta)/(redit(sqrt(v_t)+epsilon.alt)) redit(m_t)
$

看起来挺完美的. 不如代进去试一试吧.

== 问题

假设一维参数, 每轮梯度恒为 $g_t=1$, 取 $beta_1=beta_2=0.9$, $epsilon.alt=0$, $eta=0.1$.

#thinking[
  指定 $eta=0.1$, 即我们希望最大不要更新当前梯度的0.1倍.
]

RMSprop的 $v_t$:$ v_t & =0.9v_(t-1)+0.1times 1^2 \
    & =0.9v_(t-1)+0.1 $

这是一个线性递推式, 系数 $0.9 in (0,1)$, 它是收敛的. 收敛到不动点时满足 $v_t=v_(t-1)=v^*$, 解得 $v^*=1$.

它对于 $g_t$ 的缩放作用是: $ eta/(sqrt(v_t)+epsilon.alt)=0.1 $

再看看Momentum的 $m_t$:$ m_t=0.9 m_(t-1)+1 $

同样地, 它也收敛. 解得 $m_t=10$.

它对于 $g_t$ 的缩放作用是: $ m_t/g_t=10 $

它们组合起来, 参数更新量相当于是:$ Delta theta=eta/(sqrt(v_t)+epsilon.alt)dot m_t=0.1 dot 10 g_t=g_t $

这比我们期望的大了10倍.

== 尺度不同

把 $m_t$ 展开:

$
  m_t=g_t+beta_1 g_(t-1)+beta_1^2 g_(t-2)+...
$

和前面一样, 我们假设梯度序列是平稳的, 即$ g_t approx g_(t-1)approx g_(t-2)approx...approx g\ m_t approx g dot (1+beta_1+beta_1^2+...) $



#thinking[
  设级数为 $ S=1+beta_1+beta_1^2+...=sum_(n=0)^oo beta_1^n $

  这是一个等比级数, 我们外部指定了 $abs(beta_1)<1$, 这个级数是收敛的. 它的求和公式是$ S=1/(1-beta_1) $
]

因此 $ m_t approx g dot 1/(1-beta_1) $

从这里看, 级数和 $1/(1-beta_1)$ 对梯度 $g$ 具有缩放作用.

同理, 把 $v_t$ 展开:$ v_t=(1-beta_2)g_t^2+(1-beta_2)beta_2g_(t-1)^2+... $

权重之和恰好为1. $v_t$ 是一个归一化的加权平均.

== 归一化

问题知道了, 就很好修复了. 把 $m_t$ 做一个归一化就好了:$ m_t=beta_1m_(t-1)+(1-beta_1)g_t $

在稳态时可知, $m^*=1$, 它不再对 $g_t$ 有缩放作用了.

其实这里在@sec:momentum_norm 已经介绍过了🤣, 我写着写着忘了. 对不起. 不过这里写的比前面详细一些.

Adam把归一化直接放进了递归, 不需要每次额外乘系数.

== 冷启动

前面都考虑的是稳定情况, 其实冷启动也得考虑:$ m_0=0,quad v_0=0 $

这导致初期指数平均的权重几乎全都压在0上. 对 $m_t$ 取期望:$ EE[m_t]=(1-beta_1^t)EE[g_t] $

初期 $t$ 很小, 期望直接被压缩了 $(1-beta_1^t)$ 倍. 例如, $beta_1=0.9,t=1$ 时, 只有 $0.1$ 倍. $v_t$ 也有这个问题.

所以在训练初期, 有效步长被低估了. 参数在原地磨蹭. 修正也很简单, 直接把压缩的倍数除回来:$ hat(m)_t=m_t/(1-beta_1^t),quad hat(v)_t=v_t/(1-beta_2^t) $

这样, $EE[hat(m)_t]approx EE[g_t]$, 初期估计就恢复了无偏性. 随着 $t$ 的增大, $beta^t->0$, 修正项退化为1, 不影响后期训练.

在 $m_t$ 的展开式里, 初始值0相当于在序列最前面塞了 $t$ 个隐藏的0, 分母正是把这些0的权重补偿回来的.

#definition[*Adam*

  $
            m_t & =beta_1 m_(t-1)+(1-beta_1)g_t \
            v_t & =beta_2 v_(t-1)+(1-beta_2)g_t^2 \
       hat(m)_t & =m_t/(1-beta_1^t),quad hat(v)_t=v_t/(1-beta_2^t) \
    theta_(t+1) & =theta_t-eta/(sqrt(hat(v)_t+epsilon.alt))dot hat(m)_t
  $]

```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    g = batch_grad_fn(i)

    self.step_count += 1
    bias_corr1 = 1 - self.beta1 ** self.step_count
    bias_corr2 = 1 - self.beta2 ** self.step_count

    for p, grad in zip(self.params, g):
        m = self.state[p]['exp_avg']
        v = self.state[p]['exp_avg_sq']

        m.mul_(self.beta1).add_(grad, alpha=1 - self.beta1)
        v.mul_(self.beta2).add_(grad * grad, alpha=1 - self.beta2)

        m_hat = m / bias_corr1
        v_hat = v / bias_corr2

        step_size = self.lr / (v_hat.sqrt() + self.eps)
        p.add_(m_hat * step_size, alpha=-1)
```

= 来迟一步的Nadam@dozat2016incorporating

// Adam把方向平滑和尺度感知拼在了一起. 但是它的Momentum, 我们在前面已经找到了看起来比它更好的NAG. 能不能也把NAG的lookahead策略塞进Adam?

== 拼接灵感

*NAG*

$
      v_(t+1) & =beta v_t+g_t \
  theta_(t+1) & =theta_t-eta(g_t+beta v_(t+1))
$

在训练结束后, 还原真实参数, 我们还需要做一次补偿:$ theta_T^"true"=theta_T+beta eta v_T $

把NAG的 $v_t$ 与Adam里的字母对齐, 得到新的NAG定义:$  redit(m_t) & =beta m_(t-1)+g_t \
theta_(t+1) & =theta_t-eta(redit(g_t+beta m_t)) $

NAG的更新方向是 $g_t+beta m_t$, 即当前梯度 + 预支的下一步动量.

*Adam*

$
   redit(m_t) & =beta_1 m_(t-1)+(1-beta_1)g_t \
          v_t & =beta_2 v_(t-1)+(1-beta_2)g_t^2 \
     hat(m)_t & =m_t/(1-beta_1^t),quad hat(v)_t=v_t/(1-beta_2^t) \
  theta_(t+1) & =theta_t-eta/(sqrt(hat(v)_t+epsilon.alt))dot redit(hat(m)_t)
$

Adam的更新方向是修正后的 $hat(m)_t$, 即"历史共识". 能不能把NAG的预支结构移植到Adam里?

拼装直觉: 在Adam的归一化体系下, 由当前已知量 $m_t$ 和 $g_t$ 能组合出的最自然的lookahead估计是:$ redit(tilde(m)_t)=beta_1 m_t+(1-beta_1)g_t $

这恰好是Adam递归式中"下一步动量"的显式展开, 但此时我们不引入新的时间下标, 只把它看作当前已知量的组合.

== 期望错位

直接把这个 $tilde(m)_t$ 塞进Adam的更新式, 先算 $m_t$ 的期望. 把 $m_t$ 展开:$ m_t= (1-beta_1)g_t+(1-beta_1)beta_1 g_(t-1)+...+(1-beta_1)beta_1^(t-1)g_1+beta_1^t m_0 $

假设各轮梯度独立分布, $EE[g_t]=mu$, 且 $m_0=0$:$ EE[m_t] & =(1-beta_1)mu sum_(j=0)^(t-1)beta_1^j \
        & =(1-beta_1^t)mu $

Adam除以 $(1-beta_1^t)$ 修正, 得到 $EE[hat(m)_t]=mu$.

现在算 $tilde(m)_t=beta_1m_t+(1-beta_1)g_t$ 的期望:$ EE[tilde(m)_t] & =beta_1 EE[m_t]+(1-beta_1)mu \
               & =beta_1 (1-beta_1^t)mu+(1-beta_1)mu \
               & =mu[beta_1-beta_1^(t+1)+1-beta_1] \
               & =mu(1-beta_1^(t+1)) $

所以, $tilde(m)_t$ 的期望被压缩了 $(1-beta_1^(t+1))$ 倍.

== 修正

Nadam给lookahead方向配了自己的修正系数:$ hat(tilde(m))_t=tilde(m)_t/(1-beta_1^(t+1))=(beta_1 m_t+(1-beta_1)g_t)/(1-beta_1^(t+1)) $

这样就无偏了.

// 也可以用 $hat(m)_t$ 来表示:$ hat(tilde(m))_t=(beta_1(1-beta_1^t))/(1-beta_1^(t+1))hat(m)_t+(1-beta_1)/(1-beta_1^(t+1))g_t $

当 $t$ 很大时, $beta_1^t->0$, 系数分别趋近于 $beta_1$ 和 $1-beta_1$, 退化为动量和梯度的朴素加权.

#definition[*Nadam*
  $
                m_t & =beta_1 m_(t-1)+(1-beta_1)g_t \
                v_t & =beta_2 v_(t-1)+(1-beta_2)g_t^2 \
           hat(m)_t & =(m_t)/(1-beta_1^t),quad hat(v_t)=v_t/(1-beta_2^t) \
    hat(tilde(m))_t & =(beta_1 m_t+(1-beta_1)g_t)/(1-beta_1^(t+1)) \
        theta_(t+1) & =theta_t-eta/(sqrt(hat(v_t))+epsilon)dot hat(tilde(m))_t
  $
]

```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    g = batch_grad_fn(i)

    self.step_count += 1
    bias_corr1 = 1 - self.beta1 ** self.step_count
    bias_corr2 = 1 - self.beta2 ** self.step_count
    bias_corr1_next = 1 - self.beta1 ** (self.step_count + 1)

    for p, grad in zip(self.params, g):
        m = self.state[p]['exp_avg']
        v = self.state[p]['exp_avg_sq']

        m.mul_(self.beta1).add_(grad, alpha=1 - self.beta1)
        v.mul_(self.beta2).add_(grad * grad, alpha=1 - self.beta2)

        m_hat = m / bias_corr1
        v_hat = v / bias_corr2

        # Nesterov lookahead
        m_tilde = (self.beta1 * m + (1 - self.beta1) * grad) / bias_corr1_next

        step_size = self.lr / (v_hat.sqrt() + self.eps)
        p.add_(m_tilde * step_size, alpha=-1)
```

// == 与Adam的关系

// 理论上, Nadam比Adam多了一层前瞻性. 但是实际上没有取代Adam.

// === 修正的微弱性

// 设各轮随机梯度独立同分布, $EE[g_t]=mu$, 且初始向量 $m_0=0$.

// 把 $m_t$ 展开:$ m_t=(1-beta_1)g_t+(1-beta_1)beta_1 g_(t-1)+...+(1-beta_1)beta_1^(t-1)g_1+beta_1^t m_0 $

// 取期望:$ EE[m_t] & =(1-beta_1)mu sum_(j=0)^(t-1)beta_1^j +beta_1^t dot 0 \
//         & =(1-beta_1^t)mu $

// 原始 $m_t$ 与 $g_t$ 的偏差$ EE[g_t-m_t]=mu-(1-beta_1^t)mu=beta_1^t mu $

// 初期不是0, 例如 $t=1$, $beta_1=0.9$ 时, 期望偏差是 $0.9mu$.

// Adam的修正:

// $
//       hat(m)_t & =m_t/(1-beta_1^t) \
//   EE[hat(m)_t] & =EE[m_t]/(1-beta_1^t)=((1-beta_1^t)mu)/(1-beta_1^t)=mu
// $

// 因此, $EE[g_t,hat(m)_t]=mu-mu=0$.

// 对于原始 $m_t$: $EE[g_t-m_t]=beta_1^t mu$, 只在 $t->oo$ 时趋于0.

// 对修正后的 $hat(m)_t$, 它严格为0, 与 $t$ 无关.

// === Adam的Look-ahead收益

// 原始Adam已经近似等价地享受了Nadam的lookahead收益.

// Adam的更新式是$ theta_(t+1)=theta_t-eta/(sqrt(hat(v)_t)+epsilon.alt)hat(m)_t $

// 而 $hat(m)_t$ 本身带有强惯性. 当 $beta_1=0.9$ 时, $m_t$ 的变化非常缓慢, $tilde(m)_t$ 和 $m_t$ 的差异很小. 在高维非凸landscape中, 随机梯度的噪声主导了优化轨迹, 单步预支的微小差异被噪声完全淹没.

// 从工程上看, Nadam需要额外维护 $(1-beta_1^(t+1))$ 的修正系数, 还要多一次组合运算, 带来微小的overhead, 收益还不稳定.

// 在大多数任务上, Nadam和Adam的最终精度差距不大, 我们自然选择了更简洁的Adam.



= 与损失函数合作的AdamW@loshchilov2017decoupled
Loss与Optimizer的相互作用, 值得再单独谈谈 (又给自己挖个巨坑是吧😡).

== 损失正则

标准训练通常给损失函数加上L2正则:$ F(theta)=L(theta)+redit(lambda/2||theta||^2) $

其中, $L(theta)$ 是数据损失, $lambda/2||theta||^2$ 是正则项, 防止参数膨胀.

== SGD中的等价性

在SGD里, 梯度变为:$ tilde(g)_t=nabla L(theta_t)+lambda theta_t=g_t+lambda theta_t $

更新规则:$ theta_(t+1) & =theta_t-eta tilde(g)_t \
            & =theta_t-eta(g_t+lambda theta_t) \
            & =(1-eta lambda)theta_t-eta g_t $

这揭示了一个等价关系: 在SGD中, 给损失加L2正则, 和每轮更新后把参数乘以 $(1-eta lambda)$, 数学上是一回事.

== Adam中的耦合

// *Adam*

// $
//           m_t & =beta_1 m_(t-1)+(1-beta_1)g_t \
//           v_t & =beta_2 v_(t-1)+(1-beta_2)g_t^2 \
//      hat(m)_t & =m_t/(1-beta_1^t),quad hat(v)_t=v_t/(1-beta_2^t) \
//   theta_(t+1) & =theta_t-eta/(sqrt(hat(v)_t+epsilon.alt))dot hat(m)_t
// $

替换Adam定义式中的项$ tilde(g)_t & =g_t+lambda theta_t \
m_t & =beta_1 m_(t-1)+(1-beta_1)(g_t+redit(lambda theta_t)) \
v_t & =beta_2 v_(t-1)+(1-beta_2)(g_t+redit(lambda theta_t))^2 \
hat(m)_t & =m_t/(1-beta^t_1),quad hat(v)_t=v_t/(1-beta_2^t) \
theta_(t+1) & =theta_t-eta/(sqrt(hat(v)_t)+epsilon.alt)dot hat(m)_t-(eta lambda)/(sqrt(hat(v_t))+epsilon.alt)dot theta_t\ &=(1-(eta lambda)/(sqrt(hat(v)_t)+epsilon.alt))theta_t-eta/(sqrt(hat(v)_t)+epsilon.alt)dot hat(m)_t $

在SGD里, 正则项对参数的作用是均匀的缩放 $(1-eta lambda)$, 每个参数按同一比例向原点收缩. 但是现在参数 $eta_t$ 的收缩比例变成了$ (1-(eta lambda)/(sqrt(hat(v)_t)+epsilon.alt)) $

$sqrt(hat(v)_t)$ 是逐坐标不同的. 对于那些历史梯度能量大的坐标, $sqrt(hat(v)_t)$ 很大, 收缩比例接近于1 (几乎不收缩); 对于那些历史梯度能量小的坐标, $sqrt(hat(v)_t)$ 很小, 收缩比例接近 $1-eta lambda$.

L2正则的均匀收缩本意被扭曲了.

还有一个问题, 展开 $v_t$, 会有 $lambda^2 theta_t^2$ 项. 这也就意味着, 参数值本身越大, $v_t$ 越大, $eta$ 被缩放得越剧烈. 失去了对真实梯度能量的独立判断.



== 解耦

AdamW的修正很直接. 把 $lambda theta_t$ 从梯度里抽出来, 不让它进入 $m_t$ 和 $v_t$ 的递归. 正则项让它像SGD那样, 在参数更新时单独做均匀缩放.

#definition[*AdamW*

  $
            m_t & =beta_1 m_(t-1)+(1-beta_1)g_t \
            v_t & =beta_2 v_(t-1)+(1-beta_2)g_t^2 \
       hat(m)_t & =m_t/(1-beta_1^t),quad hat(v)_t=v_t/(1-beta_2^t) \
    theta_(t+1) & =(1-eta lambda)theta_t-eta/(sqrt(hat(v)_t)+epsilon.alt)dot hat(m)_t
  $]

```python
def step(self, batch_grad_fn, data_indices):
    i = random.choice(data_indices)
    g = batch_grad_fn(i)  # nabla L(theta)

    self.step_count += 1
    bias_corr1 = 1 - self.beta1 ** self.step_count
    bias_corr2 = 1 - self.beta2 ** self.step_count

    for p, grad in zip(self.params, g):
        m = self.state[p]['exp_avg']
        v = self.state[p]['exp_avg_sq']

        m.mul_(self.beta1).add_(grad, alpha=1 - self.beta1)
        v.mul_(self.beta2).add_(grad * grad, alpha=1 - self.beta2)

        m_hat = m / bias_corr1
        v_hat = v / bias_corr2

        step_size = self.lr / (v_hat.sqrt() + self.eps)
        p.add_(m_hat * step_size, alpha=-1)

        p.mul_(1 - self.lr * self.weight_decay)
```

#v(50pt)

Copyleft #math.copyleft CC-BY-SA-4.0 License.

#bibliography("ref.bib", style: "gb-7714-2015-numeric")

