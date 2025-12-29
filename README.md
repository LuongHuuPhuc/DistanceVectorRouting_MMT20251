# MÔ PHỎNG DISTANCE VECTOR ROUTING 
## 1. Giới thiệu Distance Vector Routing (DVR)
- Là thuyết toán định tuyến trong đóđó, mỗi router chi biết:
    - Chi phí từ nó đến các Router láng giềng trực tiếp
    - Bảng định tuyến của láng giềng 
- Router định kỳ trao đổi **vector khoảng cách** với láng giềng 
- Dựa trên công thức **Bellman-Ford**: 

$$ D_x(y) = \min_{v \in \text{Neighbors}(x)} \{ c(x, v) + D_v(y) \} $$

## 2. Mô hình mô phỏng 
### 2.1 Thành phần mô phỏng
| Thành phần            | Ý nghĩa             |
| --------------------- | ------------------- |
| Node                  | Router              |
| Link                  | Kết nối giữa router |
| Cost                  | Trọng số link       |
| Distance Vector Table | Bảng định tuyến     |
| Iteration             | Một chu kỳ cập nhật |

## 3. Thành phần nâng cao 
### 3.1 Count-to-Inifinity Problem (Lỗi kinh điển của Distance-Vector)
- **Count-to-Infinity** xảy ra khi: 
    - Một link bị đứt
    - Các Router không biết ngay 
    - Chúng cập nhật sai lẫn nhau, làm cho cost tăng dần, tăng dần đến vô hạn 
- Ví dụ trực quan: 
    - Giả sử có 3 Router: 
```css
A —— B —— C
```
| Link | Cost |
| ---- | ---- |
| A–B  | 1    |
| B–C  | 1    |

- Ban đầu: 
    - A → C = 2 (qua B)
    - B → C = 1
- Sự cố xảy ra:
    - Link B-C bị đứt 
    - Nhưng B chưa biết, A vẫn nói với B "Tôi đi đến C mất 2 cost" 
    - B nghĩ: $B→C=1+2=3$
    - B lại báo cho A: $A→C=1+3=4$
    - Cứ thế $2 → 3 → 4 → 5 → 6 → ... → ∞$
- Hiên tượng này được quan sát khi một liên kết bị hỏng và các router khác tiếp tục cập nhật bảng định tuyến dựa trên thông tin lỗi thời từ láng giềng
- Mô phỏng MATLAB:
```matlab
cost(2,3) = Inf;
cost(3,2) = Inf;
```
### 3.2 Link Failure Simulation (Mô phỏng đứt link)
- Ý nghĩa mô phỏng: 
    - Cáp bị đứt
    - Router chết
    - Kết nối không còn tồn tại
- Mô phỏng này để kiểm tra cho lỗi **Count-to-Infinity** và quan sát số vòng hội tụ lại
- Trong bài mô phỏng, các liên kết và Router có thể bị lỗi ngẫu nhiên nhằm phản ánh điều kiện hoạt động thực thế của mạng
- Kết quả cho thấy thuật toán Distance Vector cần cơ chế chống vòng lặp để đảm bảo hội tụ ổn định trong môi trường không tin cậy

### 3.3 Split Horizon & Poisoned Reverse 
#### Split Horizon 
- Split Horizon là hiện tượng khi Router không quảng bá một route ngược lại chính Router đã cung cấp Route đó
- Mục tiêu: Chặn vòng lặp
- Ví dụ: nếu A học được đường tới C thông qua B -> A không nói lại với B rằng A đã có đường tới C 

### Poisoned Reverse 
- Là hiện tượng thay vì không nói *"Router nói "*
### 4. Kiến trúc file MATLAB 
```css
DV_Routing_Simulation/
│
├── main.m                     % Chạy mô phỏng
├── init_topology.m            % Khởi tạo mạng
├── distance_vector_step.m     % 1 vòng cập nhật DV
├── check_convergence.m        % Kiểm tra hội tụ
├── print_routing_table.m      % In bảng định tuyến
└── README.txt                 % Giải thích lý thuyết
```


