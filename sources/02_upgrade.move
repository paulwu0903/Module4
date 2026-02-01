/** Upgrade Smart Contract
 * 需擁有 UpgradeCap Object，才能進行合約更新。
 * 部署合約時執行一次的init function，在Upgrade合約的時候，不會被執行。
 * 當你Upgrade合約後，舊版本仍可以使用。
 * 新版本必須與新版本兼容：
 *      * 現有的 public function 和 struct 定義不變。
 *      * 可新增 struct 與 function。
 *      * 可以移除泛型的 type 限制。
 *      * 可以更改 function 邏輯。
 *      * 可以更改非 public function 為 public(package)或 entry function。
 *
 * 更新合約指令： sui client upgrade --upgrade-capability {UPGRADE-CAP-ID}
 *
 * Ex: See "lesson_two.move"
 *
 */

module module_4::upgrade;
