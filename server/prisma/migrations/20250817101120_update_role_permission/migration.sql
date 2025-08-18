/*
  Warnings:

  - The `menuId` column on the `role_permissions` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - The `authType` column on the `role_permissions` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- AlterTable
ALTER TABLE "public"."role_permissions" DROP COLUMN "menuId",
ADD COLUMN     "menuId" TEXT[],
DROP COLUMN "authType",
ADD COLUMN     "authType" TEXT[];
